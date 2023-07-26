#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make DCOMPILER=ldc2

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc/bash_completion.d
cp -r bin/* ${PREFIX}/bin
install -m 644 bash_completion/tsv-utils ${PREFIX}/etc/bash_completion.d
