#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 ${SRC_DIR}/aFC.py ${PREFIX}/bin/aFC.py
