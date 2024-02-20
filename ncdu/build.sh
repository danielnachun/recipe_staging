#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [[ ${target_platform} == "linux-64" ]]; then
    zig build --prefix ${PREFIX} -Drelease-fast=true -Dcpu=core2 -Dtarget=native-native-gnu.2.17
fi
if [[ ${target_platform} == "osx-64" ]]; then
    zig build --prefix ${PREFIX} -Dpie=true -Doptimize=ReleaseFast -Dcpu=core2
fi
if [[ ${target_platform} == "osx-arm64" ]]; then
    zig build --prefix ${PREFIX} -Dpie=true -Doptimize=ReleaseFast -Dcpu=apple_m1
fi
mkdir -p ${PREFIX}/share/man/man1
install -m 755 ncdu.1 ${PREFIX}/share/man/man1/ncdu.1
