#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 "${SRC_DIR}/phASER/wrapper.py" "${PREFIX}/bin/phaser_wrapper.py"
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/bin/phaser_wrapper.py
