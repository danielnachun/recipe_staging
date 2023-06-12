#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin 
mkdir -p ${PREFIX}/libexec
install -m 755 diff-so-fancy ${PREFIX}/libexec
cp -r lib ${PREFIX}/libexec
ln -sf ${PREFIX}/libexec/diff-so-fancy ${PREFIX}/bin/diff-so-fancy
