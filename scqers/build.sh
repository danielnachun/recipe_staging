#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 scripts/MPRA_Snakemake_Pipeline/workflow/scripts/clean_up_UMI_counts_v3_20220126.R ${PREFIX}/bin/clean_up_umi_counts
install -m 755 scripts/MPRA_Snakemake_Pipeline/workflow/scripts/get_barcode_v2_fixed_pos_w_seq_check_20220201.py ${PREFIX}/bin/get_barcode_fixed_pos

sed -i '1i #!/usr/bin/env Rscript' ${PREFIX}/bin/clean_up_umi_counts
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/get_barcode_fixed_pos
