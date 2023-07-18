#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ $target_platform =~ .*linux.* ]]; then
    export CC=${BUILD_PREFIX}/bin/clang
    export CXX=${BUILD_PREFIX}/bin/clang++
fi
export OBJCFLAGS="-I${PREFIX}/include"

sed -i -e "s|gcc|${CC}|g" -e "s|g++|${CXX}|g" XADMaster/Makefile.linux
sed -i -e "s|gcc|${CC}|g" -e "s|g++|${CXX}|g" UniversalDetector/Makefile.linux

cd XADMaster
make -f Makefile.linux

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man1
mkdir -p ${PREFIX}/etc/bash_completion.d
install -m 755 unar ${PREFIX}/bin
install -m 755 lsar ${PREFIX}/bin
install -m 644 ../UniversalDetector/libUniversalDetector.a ${PREFIX}/lib
install -m 644 libXADMaster.a ${PREFIX}/lib

cd Extra
install -m 644 unar.1 ${PREFIX}/share/man1
install -m 644 lsar.1 ${PREFIX}/share/man1
install -m 644 unar.bash_completion ${PREFIX}/etc/bash_completion.d
install -m 644 lsar.bash_completion ${PREFIX}/etc/bash_completion.d
