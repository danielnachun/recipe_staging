#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export SETUPTOOLS_SCM_PRETEND_VERSION=${PKG_VERSION}
${PREFIX}/bin/python -m pip install . -vv --no-deps --no-build-isolation

mkdir -p ${PREFIX}/bin

install -m 755 src/scripts/borzoi_gtex_coef_sad.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_gtex_coef_sed.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_sad.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_satg_gene.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_satg_gene.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_satg_gene_crispr_ism_shuffle.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_satg_gene_focused_ism.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_satg_polya.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_satg_splice.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_sed.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_sed_ipaqtl_cov.py ${PREFIX}/bin
install -m 755 src/scripts/borzoi_trip.py ${PREFIX}/bin
install -m 755 src/scripts/bw_h5.py ${PREFIX}/bin
install -m 755 src/scripts/idx_genome.py ${PREFIX}/bin
install -m 755 src/scripts/w5_merge.py ${PREFIX}/bin
install -m 755 src/scripts/w5_qc.py ${PREFIX}/bin

PY_VER=$(python -V | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
SP_DIR=${PREFIX}/lib/python${PY_VER}/site-packages
mkdir -p ${SP_DIR}
install -m 644 src/scripts/pygene.py ${SP_DIR}
