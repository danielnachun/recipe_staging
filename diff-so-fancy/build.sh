#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin 
mkdir -p ${PREFIX}/libexec/diff-so-fancy
install -m 755 diff-so-fancy ${PREFIX}/libexec/diff-so-fancy
cp -r lib ${PREFIX}/libexec/diff-so-fancy
ln -sf ${PREFIX}/libexec/diff-so-fancy/diff-so-fancy ${PREFIX}/bin/diff-so-fancy
