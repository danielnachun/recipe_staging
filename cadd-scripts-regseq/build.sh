#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 ${SRC_DIR}/src/scripts/lib/tools/regulatorySequence/predictVariants.py ${PREFIX}/bin/predictVariants.py

sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/predictVariants.py
