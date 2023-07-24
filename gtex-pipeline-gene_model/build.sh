#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 "${SRC_DIR}/gene_model/collapse_annotation.py" "${PREFIX}/bin/collapse_annotation.py"
