#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 "${SRC_DIR}/genotype/compute_genotype_pcs.py" "${PREFIX}/bin/compute_genotype_pcs.py"
install -m 755 "${SRC_DIR}/genotype/shapeit2/src/aggregate_pirs.py" "${PREFIX}/bin/aggregate_pirs.py"
install -m 755 "${SRC_DIR}/genotype/shapeit2/src/bam_to_pir.py" "${PREFIX}/bin/bam_to_pir.py"
install -m 755 "${SRC_DIR}/genotype/shapeit2/src/run_shapeit.py" "${PREFIX}/bin/run_shapeit.py"
install -m 755 "${SRC_DIR}/genotype/shapeit2/src/shapeit_postprocess.py" "${PREFIX}/bin/shapeit_postprocess.py"
