#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man1
mkdir -p ${PREFIX}/etc/bash_completion.d
cd XADMaster

if [[ $target_platform =~ .*linux.* ]]; then
    export CC=${BUILD_PREFIX}/bin/clang
    export CXX=${BUILD_PREFIX}/bin/clang++
    export OBJCFLAGS="-I${PREFIX}/include"

    sed -i -e "s|gcc|${CC}|g" -e "s|g++|${CXX}|g" Makefile.linux
    sed -i -e "s|gcc|${CC}|g" -e "s|g++|${CXX}|g" ../UniversalDetector/Makefile.linux

    make -f Makefile.linux

    install -m 755 unar ${PREFIX}/bin
    install -m 755 lsar ${PREFIX}/bin
    install -m 644 ../UniversalDetector/libUniversalDetector.a ${PREFIX}/lib
    install -m 644 libXADMaster.a ${PREFIX}/lib
else
    sed -i "s/libstdc++.6.dylib/libc++.1.dylib/g" XADMaster.xcodeproj/project.pbxproj
    mkdir build
    pushd build
        xcodebuild -target XADMaster -project ../XADMaster.xcodeproj SYMROOT=${SRC_DIR}/XADMaster/build -configuration Release MACOSX_DEPLOYMENT_TARGET=10.13 ARCHS=x86_64 ONLY_ACTIVE_ARCH=YES
        xcodebuild -target unar -project ../XADMaster.xcodeproj SYMROOT=${SRC_DIR}/XADMaster/build -configuration Release MACOSX_DEPLOYMENT_TARGET=10.13 ARCHS=x86_64 ONLY_ACTIVE_ARCH=YES
        xcodebuild -target lsar -project ../XADMaster.xcodeproj SYMROOT=${SRC_DIR}/XADMaster/build -configuration Release MACOSX_DEPLOYMENT_TARGET=10.13 ARCHS=x86_64 ONLY_ACTIVE_ARCH=YES

        mkdir -p ${PREFIX}/bin
        install -m 755 Release/unar ${PREFIX}/bin
        install -m 755 Release/lsar ${PREFIX}/bin
        install -m 644 Release/libUniversalDetector.a ${PREFIX}/lib
        install -m 644 Release/libXADMaster.a ${PREFIX}/lib
    popd
fi

cd Extra
install -m 644 unar.1 ${PREFIX}/share/man1
install -m 644 lsar.1 ${PREFIX}/share/man1
install -m 644 unar.bash_completion ${PREFIX}/etc/bash_completion.d
install -m 644 lsar.bash_completion ${PREFIX}/etc/bash_completion.d
