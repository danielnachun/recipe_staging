#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

unset HTTP_PROXY
unset HTTPS_PROXY

if [[ ${target_platform} == "linux-64" ]]; then
    zig build --prefix ${PREFIX} -Dcpu=core2 -Dtarget=x86_64-linux-gnu.2.17
fi
if [[ ${target_platform} == "osx-64" ]]; then
    zig build --prefix ${PREFIX} -Dpie=true -Doptimize=ReleaseFast -Dcpu=core2
fi
if [[ ${target_platform} == "osx-arm64" ]]; then
    zig build --prefix ${PREFIX} -Dpie=true -Doptimize=ReleaseFast -Dcpu=apple_m1
fi

mkdir -p ${PREFIX}/share/man/man1
install -m 755 ncdu.1 ${PREFIX}/share/man/man1/ncdu.1
