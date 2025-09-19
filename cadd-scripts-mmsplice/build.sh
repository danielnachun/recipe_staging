#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 ${SRC_DIR}/src/scripts/lib/tools/MMSplice.py ${PREFIX}/bin/MMSplice.py

sed -i 's?/bin/env?/usr/bin/env?' ${PREFIX}/bin/MMSplice.py
