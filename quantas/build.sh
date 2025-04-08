#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

sed -i "s?/usr/bin/env perl?${PREFIX}/bin/perl?" _countit/*.pl
sed -i "s?/usr/bin/env perl?${PREFIX}/bin/perl?" _gapless/*.pl

patch_exe() {
    exe_path=$1

    sed -i 's?perl $cmdDir/??g' $exe_path
    sed -i 's?perl $progDir/??g' $exe_path
    sed -i 's?$progDir/??g' $exe_path
    sed -i 's?\.pl ? ?g' $exe_path
}

export -f patch_exe

scripts_to_patch=(
    _countit/annotate_snv.pl
    _countit/batch_bed2wig.pl
    _countit/bed2annotation.pl
    _countit/bed2gene2symbol.pl
    _countit/combine_replicates.pl
    _countit/combine_replicates_wrapper.pl
    _countit/get_apat.pl
    _countit/pairwiseExprAS_wrapper.pl
    _countit/polyA2gene.pl
    _countit/sam2unspliced.pl
    _countit/snv2splicesite.pl
    _countit/summarize_expression_wrapper.pl
    _countit/summarize_snv2splice.pl
    _countit/summarize_splice_site_usage.pl
    _countit/summarize_splicing.pl
    _countit/summarize_splicing_from_jcn_cnt.pl
    _countit/summarize_splicing_wrapper.pl
    _gapless/gapless_huge_file.pl
    _gapless/score_exon_trio.pl
)

echo ${scripts_to_patch[@]} | tr ' ' '\n' | xargs -I % bash -c "patch_exe %"

cp _countit/*.pl ${PREFIX}/bin
cp _gapless/*.pl ${PREFIX}/bin
