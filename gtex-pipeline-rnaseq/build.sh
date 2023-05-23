#!/usr/bin/env bash

install -Dm 755 "${SRC_DIR}/rnaseq/src/aggregate_rnaseqc_metrics.py" "${PREFIX}/bin/aggregate_rnaseqc_metrics.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/aggregate_rsem_results.py" "${PREFIX}/bin/aggregate_rsem_results.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/bam2coverage.py" "${PREFIX}/bin/bam2coverage.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/combine_GCTs.py" "${PREFIX}/bin/combine_GCTs.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/mpileup.py" "${PREFIX}/bin/mpileup.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/process_star_junctions.py" "${PREFIX}/bin/process_star_junctions.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/run_MarkDuplicates.py" "${PREFIX}/bin/run_MarkDuplicates.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/run_RSEM.py" "${PREFIX}/bin/run_RSEM.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/run_STAR.py" "${PREFIX}/bin/run_STAR.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/run_SamToFastq.py" "${PREFIX}/bin/run_SamToFastq.py"
install -Dm 755 "${SRC_DIR}/rnaseq/src/run_bamsync.sh" "${PREFIX}/bin/run_bamsync.sh"
install -Dm 755 "${SRC_DIR}/rnaseq/src/run_rnaseqc.py" "${PREFIX}/bin/run_rnaseqc.py"
