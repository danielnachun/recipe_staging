#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CABAL_DIR=${SRC_DIR}/.cabal
cabal v2-update
cabal v2-install \
    --extra-lib-dirs=${PREFIX}/lib \
    --constraint "lukko -ofd-locking" \
    --allow-newer=base,aeson \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
${PREFIX}/bin/cabal-plan license-report --licensedir=${SRC_DIR}/license-files exe:${PKG_NAME}
