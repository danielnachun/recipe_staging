#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

unset HTTP_PROXY
unset HTTPS_PROXY
if [[ ${target_platform} == "linux-64" ]]; then
    zig build --prefix ${PREFIX} -Drelease-fast=true -Dcpu=baseline -Dtarget=x86_64-linux-gnu.2.17
fi
if [[ ${target_platform} == "osx-64" ]]; then
    zig build --prefix ${PREFIX} -Doptimize=ReleaseFast -Dcpu=core2
fi
if [[ ${target_platform} == "osx-arm64" ]]; then
    zig build --prefix ${PREFIX} -Doptimize=ReleaseFast -Dcpu=apple_m1
fi
