#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

${PYTHON} setup.py

install -m 755 src/cpg2bed/add_loci ${PREFIX}/bin
install -m 755 src/cview/cview ${PREFIX}/bin
install -m 755 src/homog/homog ${PREFIX}/bin
install -m 755 src/pat2beta/stdin2beta ${PREFIX}/bin
install -m 755 src/pipeline_wgbs/add_cpg_counts ${PREFIX}/bin
install -m 755 src/pipeline_wgbs/match_maker ${PREFIX}/bin
install -m 755 src/pipeline_wgbs/patter ${PREFIX}/bin
install -m 755 src/pipeline_wgbs/snp_patter ${PREFIX}/bin
install -m 755 src/segment_betas/segmentor ${PREFIX}/bin

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r src/python/*.py ${PREFIX}/libexec/${PKG_NAME}

ln -sf ${PREFIX}/libexec/${PKG_NAME}/wgbs_tools.py ${PREFIX}/bin/wgbstools
