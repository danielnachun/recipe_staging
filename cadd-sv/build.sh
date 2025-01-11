#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
sed -i 's/\r$//' ${SRC_DIR}/scripts/PLIextract.R
install -m 755 ${SRC_DIR}/scripts/PLIextract.R ${PREFIX}/bin
install -m 755 ${SRC_DIR}/scripts/annotateHIC.R ${PREFIX}/bin
sed -i 's/\r$//' ${SRC_DIR}/scripts/scoring.R
install -m 755 ${SRC_DIR}/scripts/scoring.R ${PREFIX}/bin
