#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export JAVA_HOME=${BUILD_PREFIX}/lib/jvm

if [[ $target_platform =~ .*osx.* ]]; then
    sed -i "s?\$(ISYSROOT)?-isysroot ${CONDA_BUILD_SYSROOT} -I${JAVA_HOME}/include -I${BUILD_PREFIX}/lib/jvm/include/darwin?g" src/c/Makefile-macosx-universal-64.make
    sed -i "s?\$(ARCHPPC)??g" src/c/Makefile-macosx-universal-64.make
    sed -i "s?-liconv?-L${CONDA_BUILD_SYSROOT}/usr/lib -liconv?g" src/c/Makefile-macosx-universal-64.make
else
    sed -i "s?-L/usr/local/lib? -I${BUILD_PREFIX}/include -L${BUILD_PREFIX}/lib -liconv?g" src/c/Makefile-linux-x86-64.make
fi

ant -Dbits=64 -Djavac.target.version=1.6

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
cp -r lib/* ${PREFIX}/lib
cp -r bin/* ${PREFIX}/bin

if [[ $target_platform =~ .*osx.* ]]; then
    if [[ -f ${PREFIX}/lib/libwrapper.jnilib ]]; then
        ln -sf ${PREFIX}/lib/libwrapper.jnilib ${PREFIX}/lib/libwrapper.dylib
    else
        if [[ -f ${PREFIX}/lib/libwrapper.dylib ]]; then
            ln -sf ${PREFIX}/lib/libwrapper.dylib ${PREFIX}/lib/libwrapper.jnilib
        fi
    fi
fi
