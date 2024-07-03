#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm run build

mkdir -p ${PREFIX}/bin
install -m 755 bin/bibtex-tidy ${PREFIX}/bin/bibtex-tidy
