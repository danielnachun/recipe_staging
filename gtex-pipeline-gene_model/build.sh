#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/gene_model/collapse_annotation.py"
install -m 755 "${SRC_DIR}/gene_model/collapse_annotation.py" "${PREFIX}/bin/collapse_annotation.py"
