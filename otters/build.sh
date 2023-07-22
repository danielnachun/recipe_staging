#!/usr/bin/env bash 

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r PRSmodels ${PREFIX}/libexec/${PKG_NAME}
rm -rf ${PREFIX}/libexec/${PKG_NAME}/PRSmodels/__pycache__
cp -r *.py ${PREFIX}/libexec/${PKG_NAME}
chmod +x ${PREFIX}/libexec/${PKG_NAME}/imputing.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/testing.py
chmod +x ${PREFIX}/libexec/${PKG_NAME}/training.py
ln -sf ${PREFIX}/libexec/${PKG_NAME}/imputing.py ${PREFIX}/bin/imputing
ln -sf ${PREFIX}/libexec/${PKG_NAME}/testing.py ${PREFIX}/bin/testing
ln -sf ${PREFIX}/libexec/${PKG_NAME}/training.py ${PREFIX}/bin/training
