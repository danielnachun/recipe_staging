#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 scripts/get_barcode_counts/workflow/scripts/clean_up_UMI_counts_v3_20220126.R ${PREFIX}/bin/clean_up_umi_counts
install -m 755 scripts/get_barcode_counts/workflow/scripts/get_barcode_v2_fixed_pos_w_seq_check_20220201.py ${PREFIX}/bin/get_barcode_fixed_pos
install -m 755 scripts/gene_expression_processing/workflow/scripts/seurat.R ${PREFIX}/bin/seurat

sed -i '1i #!/usr/bin/env Rscript' ${PREFIX}/bin/clean_up_umi_counts
sed -i '1i #!/usr/bin/env Rscript' ${PREFIX}/bin/seurat
sed -i '1i #!/usr/bin/env python3' ${PREFIX}/bin/get_barcode_fixed_pos
