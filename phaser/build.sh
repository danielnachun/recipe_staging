#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin 
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

cp -r phaser ${PREFIX}/libexec/${PKG_NAME}
cp -r phaser_annotate ${PREFIX}/libexec/${PKG_NAME}
cp -r phaser_gene_ae ${PREFIX}/libexec/${PKG_NAME}
cp -r phaser_pop ${PREFIX}/libexec/${PKG_NAME}

sed -i 's/95%/95%%/' ${PREFIX}/libexec/${PKG_NAME}/phaser_pop/phaser_cis_var.py

sed -i 's?/home/bin/python2?/usr/bin/env python2?' ${PREFIX}/libexec/${PKG_NAME}/phaser/phaser.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/phaser_annotate/phaser_annotate.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/phaser_gene_ae/phaser_gene_ae.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/phaser_pop/phaser_cis_var.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/phaser_pop/phaser_expr_matrix.py

chmod +x ${PREFIX}/libexec/${PKG_NAME}/phaser/phaser.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/phaser_annotate/phaser_annotate.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/phaser_gene_ae/phaser_gene_ae.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/phaser_pop/phaser_cis_var.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/phaser_pop/phaser_expr_matrix.py

ln -sf ${PREFIX}/libexec/${PKG_NAME}/phaser/phaser.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/phaser_annotate/phaser_annotate.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/phaser_gene_ae/phaser_gene_ae.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/phaser_pop/phaser_cis_var.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/phaser_pop/phaser_expr_matrix.py ${PREFIX}/bin

pushd phaser
    ${PYTHON} setup.py build_ext --inplace
popd
