#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make ldc

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc/bash_completion.d
install -m 755 bin/dfmt ${PREFIX}/bin/dfmt
install -m 644 bash-completion/completions/dfmt ${PREFIX}/etc/bash_completion.d
