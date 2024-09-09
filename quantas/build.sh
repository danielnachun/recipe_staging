#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
cp _countit/*.pl ${PREFIX}/bin
cp _gapless/*.pl ${PREFIX}/bin
