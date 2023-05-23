#!/usr/bin/bash

set -o xtrace -o nounset -o pipefail -o errexit

cd dap_src
sed -i 's/-L \/usr\/local\/lib//g' Makefile
sed -i "s?g++?${CXX} -I${PREFIX}/include -L${PREFIX}/lib?g" Makefile
make
install -Dm 755 dap-g ${PREFIX}/bin/dap-g

cd ..
cd ptwas_builder
sed -i 's/-L \/usr\/local\/lib//g' Makefile
sed -i "s?g++?${CXX} -I${PREFIX}/include -L${PREFIX}/lib?g" Makefile
make 
install -D -m 755 ptwas_builder ${PREFIX}/bin/ptwas_builder

cd ..
cd utility
sed -i "s?\/usr\/bin\/perl?${PREFIX}/bin/perl?g" get_credible_set.pl
install -D -m 755 get_credible_set.pl ${PREFIX}/bin/get_credible_set.pl
install -D -m 755 merge_dapg_vcf_for_all_tissues.pl ${PREFIX}/bin/merge_dapg_vcf_for_all_tissues.pl
install -D -m 755 summarize_dapg_vcf_by_tissue.pl ${PREFIX}/bin/summarize_dapg_vcf_by_tissue.pl

cd ..
cd gtex_v8_analysis
install -D -m 755 assemble.pl ${PREFIX}/bin/assemble.pl
install -D -m 755 process.pl ${PREFIX}/bin/process.pl
