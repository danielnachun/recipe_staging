#!/usr/bin/env bash 

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/share/${PKG_NAME}
mkdir -p ${PREFIX}/share/man
mkdir -p ${PREFIX}/include/dlang/dmd
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/etc
mkdir -p ${PREFIX}/bin

cp -r dmd/compiler/samples ${PREFIX}/share/${PKG_NAME}
cp -r dmd/compiler/docs/man/* ${PREFIX}/share/man
cp -r dmd/druntime/src/* ${PREFIX}/include/dlang/dmd
cp -r phobos/std ${PREFIX}/include/dlang/dmd
cp -r phobos/etc ${PREFIX}/include/dlang/dmd
cp -r phobos/*.d ${PREFIX}/include/dlang/dmd

pushd dmd
    ldmd2 compiler/src/build.d -of=compiler/src/build -release
    ./compiler/src/build INSTALL_DIR=${PREFIX} \
        SYSCONFDIR=${PREFIX}/etc \
        BUILD=release \
        HOST_DMD=${BUILD_PREFIX}/bin/ldmd2 \
        ENABLE_RELEASE=1 \
        VERBOSE=1
popd

if [[ ${target_platform} =~ .*linux.* ]]; then
    install -m 755 dmd/generated/linux/release/64/dmd ${PREFIX}/bin/dmd
else
    install -m 755 dmd/generated/osx/release/64/dmd ${PREFIX}/bin/dmd
fi

pushd phobos
    make -f posix.mak VERSION=${SRC_DIR}/VERSION \
        INSTALL_DIR=${PREFIX} \
        MODEL=64 \
        BUILD=release \
        ENABLE_RELEASE=1 \
        PIC=1 \
        DMD=${PREFIX}/bin/dmd
popd

if [[ ${target_platform} =~ .*linux.* ]]; then
    cp -r phobos/generated/linux/release/64/libphobos2.* ${PREFIX}/lib
    cp -r dmd/generated/linux/release/64/libdruntime.a ${PREFIX}/lib
else
    cp -r phobos/generated/osx/release/64/libphobos2.* ${PREFIX}/lib
    cp -r dmd/generated/osx/release/64/libdruntime.a ${PREFIX}/lib
fi

export DFLAGS="-I${PREFIX}/include/dlang/dmd -L-L${PREFIX}/lib -fPIE"
pushd dmd
    rm -rf generated
    ./compiler/src/build INSTALL_DIR=${PREFIX} \
        SYSCONFDIR=${PREFIX}/etc \
            BUILD=release \
        HOST_DMD=${PREFIX}/bin/dmd \
        ENABLE_RELEASE=1 \
        VERBOSE=1
popd

if [[ ${target_platform} =~ .*linux.* ]]; then
    install -m 755 dmd/generated/linux/release/64/dmd ${PREFIX}/bin/dmd
else
    install -m 755 dmd/generated/osx/release/64/dmd ${PREFIX}/bin/dmd
fi

tee ${PREFIX}/etc/dmd.conf <<EOF
        [Environment]
        DFLAGS=-I${PREFIX}/include/dlang/dmd -L-L${PREFIX}/lib
EOF
