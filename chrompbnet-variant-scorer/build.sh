#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

PY_VER=$(python -V | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
SP_DIR=${PREFIX}/lib/python${PY_VER}/site-packages

sed -i 's/from utils/from chrombpnet_variant_scorer.utils/' src/generators/peak_generator.py
sed -i 's/from utils/from chrombpnet_variant_scorer.utils/' src/generators/variant_generator.py
sed -i 's/from utils/from chrombpnet_variant_scorer.utils/' src/utils/helpers.py
sed -i 's/from utils/from chrombpnet_variant_scorer.utils/' src/utils/shap_utils.py
sed -i 's/from utils/from chrombpnet_variant_scorer.utils/' src/variant_annotation.py
sed -i 's/from utils/from chrombpnet_variant_scorer.utils/' src/variant_scoring.py
sed -i 's/from utils/from chrombpnet_variant_scorer.utils/' src/variant_scoring.per_chrom.py
sed -i 's/from utils/from chrombpnet_variant_scorer.utils/' src/variant_shap.py
sed -i 's/from utils/from chrombpnet_variant_scorer.utils/' src/variant_summary_across_folds.py

sed -i 's/from generators/from chrombpnet_variant_scorer.generators/' src/variant_shap.py
sed -i 's/from generators/from chrombpnet_variant_scorer.generators/' src/utils/helpers.py
sed -i 's/from generators/from chrombpnet_variant_scorer.generators/' src/utils/shap_utils.py

mkdir -p ${SP_DIR}/chrombpnet_variant_scorer
cp -r src/generators ${SP_DIR}/chrombpnet_variant_scorer
cp -r src/utils ${SP_DIR}/chrombpnet_variant_scorer

mkdir -p ${PREFIX}/bin
install -m 755 src/hitcaller_variant.py ${PREFIX}/bin
install -m 755 src/variant_annotation.py ${PREFIX}/bin
install -m 755 src/variant_scoring.py ${PREFIX}/bin
install -m 755 src/variant_scoring.per_chrom.py ${PREFIX}/bin
install -m 755 src/variant_shap.py ${PREFIX}/bin
install -m 755 src/variant_summary_across_folds.py ${PREFIX}/bin

sed -i '1i #!/usr/bin/env python' ${PREFIX}/bin/hitcaller_variant.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/bin/variant_annotation.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/bin/variant_scoring.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/bin/variant_scoring.per_chrom.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/bin/variant_shap.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/bin/variant_summary_across_folds.py
