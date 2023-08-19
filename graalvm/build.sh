#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

touch ${BUILD_PREFIX}/lib/jvm/release

mkdir -p ${PREFIX}/lib/jvm
mkdir -p ${PREFIX}/bin
export MX_PRIMARY_SUITE_PATH=graal/vm
sed -i "s/\+(/+-(/g" graal/sdk/mx.sdk/mx_sdk_vm_impl.py

if [[ ${target_platform} =~ "osx-64" ]]; then
    mx --env ce-darwin build 
    cp -r graal/sdk/mxbuild/darwin-amd64/GRAALVM_COMMUNITY_JAVA20/**/* ${PREFIX}/lib/jvm
fi
if [[ ${target_platform} =~ "linux-64" ]]; then
    mx --env ce build 
    cp -r graal/sdk/mxbuild/linux-amd64/GRAALVM_COMMUNITY_JAVA20/**/* ${PREFIX}/lib/jvm
fi

ln -sf ${PREFIX}/lib/jvm/bin/* ${PREFIX}/bin
