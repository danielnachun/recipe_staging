#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r software/* ${PREFIX}/libexec/${PKG_NAME}
chmod 755 ${PREFIX}/libexec/${PKG_NAME}/*.py
ln -sf ${PREFIX}/libexec/${PKG_NAME}/BuildExpressionProduct.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/CovarianceBuilder.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/M00_prerequisites.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/M01_covariances_correlations.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/M02_variances.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/M03_betas.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/M04_zscores.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/MetaMany.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/MulTiXcan.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/PrediXcan.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/PrediXcanAssociation.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/Predict.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/SPrediXcan.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/SMulTiXcan.py ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/ToHDF5.py ${PREFIX}/bin
