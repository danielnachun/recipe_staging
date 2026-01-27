#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

PY_VER=$(python -V | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
SP_DIR=${PREFIX}/lib/python${PY_VER}/site-packages/leafcutter2
mkdir -p ${SP_DIR}
mkdir -p ${PREFIX}/bin

sed -i 's/import ForwardSpliceJunctionClassifier/import leafcutter2.ForwardSpliceJunctionClassifier\nimport leafcutter2.Transcript_tools/' scripts/leafcutter2.py
sed -i 's/import add_on_scripts/import leafcutter2.add_on_scripts/' scripts/leafcutter2.py

install -m 755 ${SRC_DIR}/scripts/leafcutter2.py ${PREFIX}/bin/leafcutter2
install -m 755 ${SRC_DIR}/scripts/leafcutter_make_clusters.py ${PREFIX}/bin/leafcutter_make_clusters

install -m 644 ${SRC_DIR}/scripts/ForwardSpliceJunctionClassifier.py ${SP_DIR}
install -m 644 ${SRC_DIR}/scripts/Transcript_tools.py ${SP_DIR}
mkdir -p ${SP_DIR}/add_on_scripts
install -m 644 ${SRC_DIR}/scripts/add_on_scripts/Reformat_gtf.py ${SP_DIR}/add_on_scripts
