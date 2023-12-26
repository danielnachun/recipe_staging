#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pushd libStatGen
make clean
make CXX="${CXX} -I${PREFIX}/include -std=c++14 -Wno-deprecated -L${PREFIX}/lib" CC="${CC} -I${PREFIX}/include -L${PREFIX}/lib"
popd

make clean
make CPP="${CXX} -I${PREFIX}/include -L${PREFIX}/lib -std=c++14" LIBS_LNX_S_LAPACK=

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/bgw-twas
cp -r bin/* ${PREFIX}/libexec/bgw-twas
chmod +x ${PREFIX}/libexec/bgw-twas/Step1_get_sumstat.sh
chmod +x ${PREFIX}/libexec/bgw-twas/Step2_prune.sh
chmod +x ${PREFIX}/libexec/bgw-twas/Step3_EM-MCMC.sh
chmod +x ${PREFIX}/libexec/bgw-twas/Step4_get_test_grex.sh
ln -sf ${PREFIX}/libexec/bgw-twas/Step1_get_sumstat.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/bgw-twas/Step2_prune.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/bgw-twas/Step3_EM-MCMC.sh ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/bgw-twas/Step4_get_test_grex.sh ${PREFIX}/bin
sed -i "s?/usr/bin/bash?/usr/bin/env bash?" ${PREFIX}/libexec/bgw-twas/Step1_get_sumstat.sh
sed -i "s?/usr/bin/bash?/usr/bin/env bash?" ${PREFIX}/libexec/bgw-twas/Step2_prune.sh
sed -i "s?/usr/bin/bash?/usr/bin/env bash?" ${PREFIX}/libexec/bgw-twas/Step3_EM-MCMC.sh
sed -i "s?/usr/bin/bash?/usr/bin/env bash?" ${PREFIX}/libexec/bgw-twas/Step4_get_test_grex.sh
