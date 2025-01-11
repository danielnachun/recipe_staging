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
sed -i 's/from ConfigParser import ConfigParser/from configparser import ConfigParser/g' ${PREFIX}/bin/annotateVEPvcf.py
sed -i 's/lib.Annotations/cadd.Annotations/g' ${PREFIX}/bin/annotateVEPvcf.py

sed -i 's/from lib import EDict/from cadd import EDict/' ${PREFIX}/bin/appendPHREDscore.py

sed -i 's?/bin/env?/usr/bin/env?' ${PREFIX}/bin/predictSKmodel.py
sed -i 's/from sklearn.externals import joblib/import joblib/' ${PREFIX}/bin/predictSKmodel.py

sed -i 's/from lib.columnInfo import get_columns/from cadd.columnInfo import get_columns/' ${PREFIX}/bin/trackTransformation.py

rm -rf src/scripts/lib/tools
PY_VER=$(python -V | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
SP_DIR=${PREFIX}/lib/python${PY_VER}/site-packages
cp -r src/scripts/lib ${SP_DIR}/cadd

sed -i 's/from AnalysisLib import get_range_from_tabix/from cadd.AnalysisLib import get_range_from_tabix/' ${SP_DIR}/cadd/Annotations.py
sed -i 's/string.maketrans/str.maketrans/' ${SP_DIR}/cadd/AnalysisLib.py
sed -i 's/from tracks import trackData/from cadd.tracks import trackData/' ${SP_DIR}/cadd/columnInfo.py
sed -i 's/from ConfigParser import ConfigParser/from configparser import ConfigParser/g' ${SP_DIR}/cadd/columnInfo.py
