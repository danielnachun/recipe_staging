#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin 
mkdir -p ${PREFIX}/libexec/tigar
cp -r * ${PREFIX}/libexec/tigar

# Remove vendored copy of DPR and replace it with symlink to conda copy.
rm ${PREFIX}/libexec/tigar/Model_Train_Pred/DPR
ln -s ${PREFIX}/bin/DPR ${PREFIX}/libexec/tigar/Model_Train_Pred/DPR

chmod 755 ${PREFIX}/libexec/tigar/*.sh
ln -sf ${PREFIX}/libexec/tigar/TIGAR_GReX_Pred.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/tigar/TIGAR_LD.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/tigar/TIGAR_Model_Train.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/tigar/TIGAR_TWAS.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/tigar/TIGAR_VC_TWAS.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/tigar/VC_TWAS_summary.sh ${PREFIX}/bin
