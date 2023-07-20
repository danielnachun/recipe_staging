#!/usr/bin/bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin

pushd dap_src
    sed -i 's/-L \/usr\/local\/lib//g' Makefile
    sed -i "s?g++?${CXX} -I${PREFIX}/include -L${PREFIX}/lib?g" Makefile
    make
    install -m 755 dap-g ${PREFIX}/bin/dap-g
popd

pushd ptwas_builder
    sed -i 's/-L \/usr\/local\/lib//g' Makefile
    sed -i "s?g++?${CXX} -I${PREFIX}/include -L${PREFIX}/lib?g" Makefile
    make 
    install -m 755 ptwas_builder ${PREFIX}/bin/ptwas_builder
popd

pushd utility
    sed -i "s?\/usr\/bin\/perl?${PREFIX}/bin/perl?g" get_credible_set.pl
    install -m 755 get_credible_set.pl ${PREFIX}/bin/get_credible_set.pl
    install -m 755 merge_dapg_vcf_for_all_tissues.pl ${PREFIX}/bin/merge_dapg_vcf_for_all_tissues.pl
    install -m 755 summarize_dapg_vcf_by_tissue.pl ${PREFIX}/bin/summarize_dapg_vcf_by_tissue.pl
popd

pushd gtex_v8_analysis
    install -m 755 assemble.pl ${PREFIX}/bin/assemble.pl
    install -m 755 process.pl ${PREFIX}/bin/process.pl
popd
