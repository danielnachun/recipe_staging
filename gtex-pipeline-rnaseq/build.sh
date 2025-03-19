#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/aggregate_rnaseqc_metrics.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/aggregate_rsem_results.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/bam2coverage.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/combine_GCTs.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/dapars.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/mpileup.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/process_star_junctions.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/run_MarkDuplicates.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/run_RSEM.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/run_STAR.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/run_SamToFastq.py"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/run_bamsync.sh"
sed -i "s?/usr/bin/env python3?${PREFIX}/bin/python3?" "${SRC_DIR}/rnaseq/src/run_rnaseqc.py"

install -m 755 "${SRC_DIR}/rnaseq/src/aggregate_rnaseqc_metrics.py" "${PREFIX}/bin/aggregate_rnaseqc_metrics.py"
install -m 755 "${SRC_DIR}/rnaseq/src/aggregate_rsem_results.py" "${PREFIX}/bin/aggregate_rsem_results.py"
install -m 755 "${SRC_DIR}/rnaseq/src/bam2coverage.py" "${PREFIX}/bin/bam2coverage.py"
install -m 755 "${SRC_DIR}/rnaseq/src/combine_GCTs.py" "${PREFIX}/bin/combine_GCTs.py"
install -m 755 "${SRC_DIR}/rnaseq/src/dapars.py" "${PREFIX}/bin/dapars.py"
install -m 755 "${SRC_DIR}/rnaseq/src/mpileup.py" "${PREFIX}/bin/mpileup.py"
install -m 755 "${SRC_DIR}/rnaseq/src/process_star_junctions.py" "${PREFIX}/bin/process_star_junctions.py"
install -m 755 "${SRC_DIR}/rnaseq/src/run_MarkDuplicates.py" "${PREFIX}/bin/run_MarkDuplicates.py"
install -m 755 "${SRC_DIR}/rnaseq/src/run_RSEM.py" "${PREFIX}/bin/run_RSEM.py"
install -m 755 "${SRC_DIR}/rnaseq/src/run_STAR.py" "${PREFIX}/bin/run_STAR.py"
install -m 755 "${SRC_DIR}/rnaseq/src/run_SamToFastq.py" "${PREFIX}/bin/run_SamToFastq.py"
install -m 755 "${SRC_DIR}/rnaseq/src/run_bamsync.sh" "${PREFIX}/bin/run_bamsync.sh"
install -m 755 "${SRC_DIR}/rnaseq/src/run_rnaseqc.py" "${PREFIX}/bin/run_rnaseqc.py"
sed -i "1i #!${PREFIX}/bin/python3" "${PREFIX}/bin/process_star_junctions.py"
