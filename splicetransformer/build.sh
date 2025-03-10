#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

PY_VER=$(python -V | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
SP_DIR=${PREFIX}/lib/python${PY_VER}/site-packages
mkdir -p ${SP_DIR}/sptransformer

sed -i 's/from model/from sptransformer.model/' tasks_annotate_mutations.py
sed -i 's/from tasks_annotate_mutations/from sptransformer.tasks_annotate_mutations/' sptransformer.py
sed -i '1i #!/usr/bin/env python3' sptransformer.py

cp -r ${SRC_DIR}/model ${SP_DIR}/sptransformer
install -m 644 tasks_annotate_mutations.py ${SP_DIR}/sptransformer

mkdir -p ${PREFIX}/bin
install -m 755 sptransformer.py ${PREFIX}/bin
