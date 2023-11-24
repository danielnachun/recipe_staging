#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Delete vendored boost
rm -rf boost
rm tools/genome_sam_collapser.so

make CC="${CXX}" CFLAGS="-Wall -c ${CFLAGS}" LFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
install -m 755 mipgen ${PREFIX}/bin

cd tools
export CFLAGS="-I${PREFIX}/lib/python2.7/site-packages/numpy/core/include"
${PYTHON} setup.py build_ext --inplace
install -m 755 genome_sam_collapser.so ${PREFIX}/libexec/${PKG_NAME}
install -m 755 complexity_to_basewise.sh ${PREFIX}/libexec/${PKG_NAME}
install -m 755 extract_coding_gene_exons.sh ${PREFIX}/libexec/${PKG_NAME}
install -m 755 extract_gene_exons_plus_utrs.sh ${PREFIX}/libexec/${PKG_NAME}

install -m 755 generate_ucsc_track.py ${PREFIX}/libexec/${PKG_NAME}
install -m 755 mipgen_fq_cutter_pe.py ${PREFIX}/libexec/${PKG_NAME}
install -m 755 mipgen_fq_cutter_se.py ${PREFIX}/libexec/${PKG_NAME}
install -m 755 mipgen_pipeline_builder.py ${PREFIX}/libexec/${PKG_NAME}
install -m 755 mipgen_qseq2fq.py ${PREFIX}/libexec/${PKG_NAME}
install -m 755 mipgen_smmip_collapser.py ${PREFIX}/libexec/${PKG_NAME}
install -m 755 prepare_mip_reference.py ${PREFIX}/libexec/${PKG_NAME}

# Insert shebangs for Python scripts
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/generate_ucsc_track.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/mipgen_fq_cutter_pe.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/mipgen_fq_cutter_se.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/mipgen_pipeline_builder.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/mipgen_qseq2fq.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/mipgen_smmip_collapser.py
sed -i '1i #!/usr/bin/env python2' ${PREFIX}/libexec/${PKG_NAME}/prepare_mip_reference.py

ln -sf ${PREFIX}/libexec/${PKG_NAME}/generate_ucsc_track.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mipgen_fq_cutter_pe.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mipgen_fq_cutter_se.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mipgen_pipeline_builder.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mipgen_qseq2fq.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mipgen_smmip_collapser.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/prepare_mip_reference.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/complexity_to_basewise.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/extract_coding_gene_exons.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/extract_gene_exons_plus_utrs.sh ${PREFIX}/bin
