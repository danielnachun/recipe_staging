#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

if [[ ${target_platform} =~ .*osx.* ]]; then
    mkdir -p ${PREFIX}/lib/jvm
    cp -r Contents/Home/* ${PREFIX}/lib/jvm
    ln -sf ${PREFIX}/lib/jvm/bin/native-image ${PREFIX}/bin
    ln -sf ${PREFIX}/lib/jvm/bin/native-image-configure ${PREFIX}/bin

    # Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
    # This will allow them to be run on environment activation.
    for CHANGE in "activate" "deactivate"
    do
        mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
        cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    done

    #mx --env ce-darwin build 
    #cp -r graal/sdk/mxbuild/darwin-amd64/GRAALVM_COMMUNITY_JAVA23/**/* ${PREFIX}/lib/jvm
fi
if [[ ${target_platform} =~ "linux-64" ]]; then
    touch ${BUILD_PREFIX}/lib/jvm/release
    mkdir -p ${PREFIX}/lib/jvm
    export MX_PRIMARY_SUITE_PATH=graal/vm
    sed -i "s/\+(/+-(/g" graal/sdk/mx.sdk/mx_sdk_vm_impl.py
    sed -i "s?CC=<path:LLVM_TOOLCHAIN>/bin/clang?CC=${CC}?" graal/sdk/mx.sdk/suite.py
    sed -i "s?CXX=<path:LLVM_TOOLCHAIN>/bin/clang++?CXX=${CXX}?" graal/sdk/mx.sdk/suite.py
    sed -i "s?AR=<path:LLVM_TOOLCHAIN>/bin/llvm-ar?AR=${AR}?" graal/sdk/mx.sdk/suite.py
    sed -i "s?LDFLAGS=-fuse-ld=lld?LDFLAGS=${LDFLAGS}\nCFLAGS=${CFLAGS}\nCXXFLAGS=${CXXFLAGS}?g" graal/sdk/mx.sdk/suite.py
    mx --env ce build 
    cp -r graal/sdk/mxbuild/linux-amd64/GRAALVM_COMMUNITY_JAVA21/**/* ${PREFIX}/lib/jvm
    ln -sf ${PREFIX}/lib/jvm/bin/* ${PREFIX}/bin
fi

