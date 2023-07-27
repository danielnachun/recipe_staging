#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

zig build --prefix ${PREFIX} -Drelease-fast=true -Dcpu=core2 -Dtarget=native-native-gnu.2.17
mkdir -p ${PREFIX}/share/man/man1
install -m 755 ncdu.1 ${PREFIX}/share/man/man1/ncdu.1
