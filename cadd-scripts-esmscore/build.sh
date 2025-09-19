#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 ${SRC_DIR}/src/scripts/lib/tools/esmScore/esmScore_frameshift_av.py ${PREFIX}/bin/esmScore_frameshift_av.py
install -m 755 ${SRC_DIR}/src/scripts/lib/tools/esmScore/esmScore_inFrame_av.py ${PREFIX}/bin/esmScore_inFrame_av.py
install -m 755 ${SRC_DIR}/src/scripts/lib/tools/esmScore/esmScore_missense_av_fast.py ${PREFIX}/bin/esmScore_missense_av_fast.py

sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/esmScore_frameshift_av.py
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/esmScore_inFrame_av.py
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/esmScore_missense_av_fast.py
sed -i 's/esm_lib/cadd.esm_lib/g' ${PREFIX}/bin/esmScore_missense_av_fast.py

PY_VER=$(python -V | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
SP_DIR=${PREFIX}/lib/python${PY_VER}/site-packages
mkdir ${SP_DIR}/cadd
install -m 644 ${SRC_DIR}/src/scripts/lib/tools/esmScore/esm_lib.py ${SP_DIR}/cadd/esm_lib.py
