#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 puffin.py ${PREFIX}/bin/puffin
install -m 755 puffin_D.py ${PREFIX}/bin/puffin_D

sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/puffin
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/puffin_D
