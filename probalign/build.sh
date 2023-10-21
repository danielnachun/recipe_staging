#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make CXX=${CXX}

mkdir -p ${PREFIX}/bin
install -m 755 probalign ${PREFIX}/bin
