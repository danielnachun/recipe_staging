#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

zig build --prefix ${PREFIX} -Dpie=true -Doptimize=ReleaseFast -Dcpu=core2
mkdir -p ${PREFIX}/share/man/man1
install -m 755 ncdu.1 ${PREFIX}/share/man/man1/ncdu.1
