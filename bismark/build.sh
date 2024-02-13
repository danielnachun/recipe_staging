#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/share/${PKG_NAME}

cp -r docs ${PREFIX}/share/${PKG_NAME}
cp -r plotly ${PREFIX}/share/${PKG_NAME}
cp -r test_files ${PREFIX}/share/${PKG_NAME}
cp -r test_data.fastq ${PREFIX}/share/${PKG_NAME}

install -m 644 NOMe_filtering ${PREFIX}/bin/
install -m 644 bam2nuc ${PREFIX}/bin/
install -m 644 bismark ${PREFIX}/bin/
install -m 644 bismark2bedGraph ${PREFIX}/bin/
install -m 644 bismark2report ${PREFIX}/bin/
install -m 644 bismark2summary ${PREFIX}/bin/
install -m 644 bismark_genome_preparation ${PREFIX}/bin/
install -m 644 bismark_methylation_extractor ${PREFIX}/bin/
install -m 644 coverage2cytosine ${PREFIX}/bin/
install -m 644 deduplicate_bismark ${PREFIX}/bin/
install -m 644 filter_non_conversion ${PREFIX}/bin/
install -m 644 merge_arbitrary_coverage_files.py ${PREFIX}/bin/
install -m 644 merge_coverage_files_ARGV.py ${PREFIX}/bin/
install -m 644 methylation_consistency ${PREFIX}/bin/
