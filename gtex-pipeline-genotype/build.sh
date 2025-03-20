#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3" "${SRC_DIR}/genotype/compute_genotype_pcs.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3" "${SRC_DIR}/genotype/shapeit2/src/aggregate_pirs.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3" "${SRC_DIR}/genotype/shapeit2/src/bam_to_pir.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3" "${SRC_DIR}/genotype/shapeit2/src/run_shapeit.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3" "${SRC_DIR}/genotype/shapeit2/src/shapeit_postprocess.py"

install -m 755 "${SRC_DIR}/genotype/compute_genotype_pcs.py" "${PREFIX}/bin/compute_genotype_pcs.py"
install -m 755 "${SRC_DIR}/genotype/shapeit2/src/aggregate_pirs.py" "${PREFIX}/bin/aggregate_pirs.py"
install -m 755 "${SRC_DIR}/genotype/shapeit2/src/bam_to_pir.py" "${PREFIX}/bin/bam_to_pir.py"
install -m 755 "${SRC_DIR}/genotype/shapeit2/src/run_shapeit.py" "${PREFIX}/bin/run_shapeit.py"
install -m 755 "${SRC_DIR}/genotype/shapeit2/src/shapeit_postprocess.py" "${PREFIX}/bin/shapeit_postprocess.py"

sed -i "1i #!${PREFIX}/bin/python3" "${PREFIX}/bin/shapeit_postprocess.py"
