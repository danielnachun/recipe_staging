#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

install -m 755 analysis_intervening_genes.py ${PREFIX}/bin
install -m 755 step1_make_dists.py ${PREFIX}/bin
install -m 755 step2_filter_pairs.py ${PREFIX}/bin
install -m 755 step3_find_og_commus.py ${PREFIX}/bin
install -m 755 step4_OG_communities_to_blocks_graph_check.py ${PREFIX}/bin

PY_VER=$(python -V | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
SP_DIR=${PREFIX}/lib/python${PY_VER}/site-packages
cp -r ${SRC_DIR}/synphoni ${SP_DIR}
