#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

install -m 755 IPAFinder_DetectIPA.py ${PREFIX}/bin/IPAFinder_DetectIPA
install -m 755 IPAFinder_GetAnno.py ${PREFIX}/bin/IPAFinder_GetAnno
install -m 755 Paired\ samples/IPAFinder_PS_FDR.py ${PREFIX}/bin/IPAFinder_PS_FDR
install -m 755 Paired\ samples/IPAFinder_PS_FET.py ${PREFIX}/bin/IPAFinder_PS_FET
install -m 755 Population\ level\ IPA\ analysis/IPAFinder_DetectIPA.py ${PREFIX}/bin/IPAFinder_DetectIPA_population
install -m 755 Population\ level\ IPA\ analysis/IPAFinder_MergeIPA.py ${PREFIX}/bin/IPAFinder_MergeIPA
install -m 755 Population\ level\ IPA\ analysis/IPAFinder_Population.py ${PREFIX}/bin/IPAFinder_Population
install -m 755 Population\ level\ IPA\ analysis/IPAFinder_QuanIPA.py ${PREFIX}/bin/IPAFinder_QuanIPA

sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_DetectIPA
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_GetAnno
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_PS_FDR
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_PS_FET
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_DetectIPA_population
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_MergeIPA
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_Population
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/IPAFinder_QuanIPA
