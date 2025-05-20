#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

sed -i '1i #!/usr/bin/env python3' workflow/scripts/debarcode.py
sed -i '1i #!/usr/bin/env python3' workflow/scripts/filter_cellranger_gtf_file.py
sed -i '1i #!/usr/bin/env python3' workflow/scripts/remove_LA_duplicates.py
sed -i '1i #!/usr/bin/env awk -f' workflow/scripts/get_cell_barcode.awk
sed -i '1i #!/usr/bin/env awk -f' workflow/scripts/get_passed_cells_barcodes.awk

install -m 755 workflow/scripts/debarcode.py ${PREFIX}/bin/debarcode
install -m 755 workflow/scripts/filter_cellranger_gtf_file.py ${PREFIX}/bin/filter_cellranger_gtf_file
install -m 755 workflow/scripts/remove_LA_duplicates.py ${PREFIX}/bin/remove_LA_duplicates
install -m 755 workflow/scripts/get_cell_barcode.awk ${PREFIX}/bin/get_cell_barcode
install -m 755 workflow/scripts/get_passed_cells_barcodes.awk ${PREFIX}/bin/get_passed_cells_barcodes

sed -i '1i #!/usr/bin/env Rscript' workflow/scripts/func.R
sed -i '/func.R/d' workflow/scripts/pick_cells.R

install -m 755 workflow/scripts/func.R ${PREFIX}/bin/pick_cells
cat workflow/scripts/pick_cells.R >> ${PREFIX}/bin/pick_cells
