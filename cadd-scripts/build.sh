#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 ${SRC_DIR}/src/scripts/annotateVEPvcf.py ${PREFIX}/bin/annotateVEPvcf.py
install -m 755 ${SRC_DIR}/src/scripts/appendPHREDscore.py ${PREFIX}/bin/appendPHREDscore.py
install -m 755 ${SRC_DIR}/src/scripts/extract_scored.py ${PREFIX}/bin/extract_scored.py
install -m 755 ${SRC_DIR}/src/scripts/max_line_hierarchy.py ${PREFIX}/bin/max_line_hierarchy.py
install -m 755 ${SRC_DIR}/src/scripts/predictSKmodel.py ${PREFIX}/bin/predictSKmodel.py
install -m 755 ${SRC_DIR}/src/scripts/trackTransformation.py ${PREFIX}/bin/trackTransformation.py
install -m 755 ${SRC_DIR}/src/scripts/VCF2vepVCF.py ${PREFIX}/bin/VCF2vepVCF.py

sed -i '1i #!/usr/bin/env python' ${PREFIX}/bin/annotateVEPvcf.py

sed -i 's?/bin/env?/usr/bin/env?' ${PREFIX}/bin/predictSKmodel.py
sed -i 's/from sklearn.externals import joblib/import joblib/' ${PREFIX}/bin/predictSKmodel.py

rm -rf src/scripts/lib/tools
PY_VER=$(python -V | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
SP_DIR=${PREFIX}/lib/python${PY_VER}/site-packages
cp src/scripts/lib/* ${SP_DIR}
