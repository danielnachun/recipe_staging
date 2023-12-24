#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 "${SRC_DIR}/qtl/src/ase_aggregate_by_individual.py" "${PREFIX}/bin/ase_aggregate_by_individual.py"
install -m 755 "${SRC_DIR}/qtl/src/ase_calculate_lamp.py" "${PREFIX}/bin/ase_calculate_lamp.py"
install -m 755 "${SRC_DIR}/qtl/src/combine_covariates.py" "${PREFIX}/bin/combine_covariates.py"
install -m 755 "${SRC_DIR}/qtl/src/combine_signif_pairs.py" "${PREFIX}/bin/combine_signif_pairs.py"
install -m 755 "${SRC_DIR}/qtl/src/convert_vep.py" "${PREFIX}/bin/convert_vep.py"
install -m 755 "${SRC_DIR}/qtl/src/eqtl_prepare_expression.py" "${PREFIX}/bin/eqtl_prepare_expression.py"
install -m 755 "${SRC_DIR}/qtl/src/metasoft_postprocess.py" "${PREFIX}/bin/metasoft_postprocess.py"
install -m 755 "${SRC_DIR}/qtl/src/metasoft_prepare_input.py" "${PREFIX}/bin/metasoft_prepare_input.py"
install -m 755 "${SRC_DIR}/qtl/src/run_GATK_ASEReadCounter.py" "${PREFIX}/bin/run_GATK_ASEReadCounter.py"
install -m 755 "${SRC_DIR}/qtl/src/run_PEER.R" "${PREFIX}/bin/run_PEER.R"
install -m 755 "${SRC_DIR}/qtl/src/run_metasoft.py" "${PREFIX}/bin/run_metasoft.py"
install -m 755 "${SRC_DIR}/qtl/leafcutter/src/cluster_prepare_fastqtl.py" "${PREFIX}/bin/cluster_prepare_fastqtl.py"
install -m 755 "${SRC_DIR}/qtl/leafcutter/src/map_clusters_to_genes.R" "${PREFIX}/bin/map_clusters_to_genes.R"
install -m 755 "${SRC_DIR}/qtl/torus/src/run_torus.py" "${PREFIX}/bin/run_torus.py"
sed -i '1i #!/usr/bin/env python3' "${PREFIX}/bin/ase_aggregate_by_individual.py"
sed -i '1i #!/usr/bin/env python3' "${PREFIX}/bin/cluster_prepare_fastqtl.py"
sed -i '1i #!/usr/bin/env python3' "${PREFIX}/bin/run_torus.py"
sed -i '1i #!/usr/bin/env Rscript' "${PREFIX}/bin/map_clusters_to_genes.R"
