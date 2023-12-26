#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin 
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

cp -r CHT ${PREFIX}/libexec/${PKG_NAME}
cp -r mapping ${PREFIX}/libexec/${PKG_NAME}
cp -r snp2h5 ${PREFIX}/libexec/${PKG_NAME}

pushd snp2h5
    make HDF_INSTALL=${PREFIX}
    install -m 755 snp2h5 ${PREFIX}/bin/snp2h5
    install -m 755 fasta2h5 ${PREFIX}/bin/fasta2h5
popd

ln -sf ${PREFIX}/libexec/${PKG_NAME}/CHT/bam2h5.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/CHT/combined_test.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/CHT/extract_haplotype_read_counts.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/CHT/fit_as_coefficients.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/CHT/fit_bnb_coefficients.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/CHT/get_target_regions.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/CHT/simulate_counts.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/CHT/update_het_probs.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/CHT/update_total_depth.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mapping/extract_impute_snps.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mapping/extract_vcf_snps.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mapping/filter_remapped_reads.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mapping/find_intersecting_snps.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mapping/get_as_counts.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mapping/rmdup.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mapping/rmdup_pe.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mapping/sim_reads/run_sim_pe_reads.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/mapping/sim_reads/sim_pe_reads.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/snp2h5/get_sample_names.py ${PREFIX}/bin

chmod +x ${PREFIX}/libexec/${PKG_NAME}/CHT/bam2h5.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/CHT/combined_test.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/CHT/extract_haplotype_read_counts.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/CHT/fit_as_coefficients.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/CHT/fit_bnb_coefficients.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/CHT/get_target_regions.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/CHT/simulate_counts.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/CHT/update_het_probs.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/CHT/update_total_depth.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/mapping/extract_impute_snps.sh
chmod +x ${PREFIX}/libexec/${PKG_NAME}/mapping/extract_vcf_snps.sh
chmod +x ${PREFIX}/libexec/${PKG_NAME}/mapping/filter_remapped_reads.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/mapping/find_intersecting_snps.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/mapping/get_as_counts.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/mapping/rmdup.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/mapping/rmdup_pe.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/mapping/sim_reads/run_sim_pe_reads.sh
chmod +x ${PREFIX}/libexec/${PKG_NAME}/mapping/sim_reads/sim_pe_reads.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/snp2h5/get_sample_names.py

sed -i 's?/bin/env?/usr/bin/env?' ${PREFIX}/libexec/${PKG_NAME}/CHT/bam2h5.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/CHT/combined_test.py
sed -i 's?/bin/env?/usr/bin/env?' ${PREFIX}/libexec/${PKG_NAME}/CHT/extract_haplotype_read_counts.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/CHT/fit_as_coefficients.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/CHT/fit_bnb_coefficients.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/CHT/get_target_regions.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/CHT/simulate_counts.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/CHT/update_het_probs.py
sed -i 's?/bin/env?/usr/bin/env?' ${PREFIX}/libexec/${PKG_NAME}/CHT/update_total_depth.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/mapping/filter_remapped_reads.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/mapping/find_intersecting_snps.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/mapping/get_as_counts.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/mapping/rmdup.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/mapping/rmdup_pe.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/mapping/sim_reads/sim_pe_reads.py
sed -i '1i #!/usr/bin/env python' ${PREFIX}/libexec/${PKG_NAME}/snp2h5/get_sample_names.py
