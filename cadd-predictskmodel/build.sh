#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 ${SRC_DIR}/src/scripts/predictSKmodel.py ${PREFIX}/bin/predictSKmodel.py

sed -i 's?/bin/env?/usr/bin/env?' ${PREFIX}/bin/predictSKmodel.py
sed -i 's/from sklearn.externals import joblib/import joblib/' ${PREFIX}/bin/predictSKmodel.py
