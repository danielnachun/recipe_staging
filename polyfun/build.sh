#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r "${SRC_DIR}"/* "${PREFIX}/libexec/${PKG_NAME}"

mkdir -p ${PREFIX}/bin
ln -sf "${PREFIX}/libexec/${PKG_NAME}/munge_polyfun_sumstats.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/libexec/${PKG_NAME}/polyfun.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/libexec/${PKG_NAME}/polyloc.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/libexec/${PKG_NAME}/extract_snpvar.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/libexec/${PKG_NAME}/finemapper.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/libexec/${PKG_NAME}/test_polyfun.py" "${PREFIX}/bin"
