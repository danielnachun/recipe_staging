#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CABAL_DIR=${SRC_DIR}/.cabal
sed -i 's/-Werror//g' ${PKG_NAME}.cabal
cabal v2-update
cabal v2-install \
    --extra-lib-dirs=${PREFIX}/lib \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
cabal-plan license-report --licensedir=${SRC_DIR}/license-files exe:${PKG_NAME}
