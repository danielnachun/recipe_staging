#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin 
mkdir -p ${PREFIX}/libexec/fusion_twas
cp *.R ${PREFIX}/libexec/fusion_twas
cp glist-hg19 ${PREFIX}/libexec/fusion_twas
cp -r utils ${PREFIX}/libexec/fusion_twas

env_script() {
    bin_name=$1
    bin_basename=$(basename $bin_name)
    new_bin_name="${PREFIX}/bin/${bin_basename/\.R/}"
    echo "#!${PREFIX}/bin/Rscript" > $new_bin_name
    cat ${bin_name} >> $new_bin_name
    chmod 755 $new_bin_name
}

env_script ${PREFIX}/libexec/fusion_twas/FUSION.assoc_test.R
env_script ${PREFIX}/libexec/fusion_twas/FUSION.compute_weights.R
env_script ${PREFIX}/libexec/fusion_twas/FUSION.post_process.R
env_script ${PREFIX}/libexec/fusion_twas/utils/FUSION.profile_wgt.R
env_script ${PREFIX}/libexec/fusion_twas/utils/compare_models.R
env_script ${PREFIX}/libexec/fusion_twas/utils/make_score.R
