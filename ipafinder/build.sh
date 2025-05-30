#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

install -m 755 IPAFinder_DetectIPA.py ${PREFIX}/bin/IPAFinder_DetectIPA
install -m 755 IPAFinder_GetAnno.py ${PREFIX}/bin/IPAFinder_GetAnno

sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_DetectIPA
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_GetAnno
