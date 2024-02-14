#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cp ${RECIPE_DIR}/cabal.project ${SRC_DIR}

cabal v2-update
cabal --store-dir=${SRC_DIR}/.cabal v2-install \
    --extra-lib-dirs=${PREFIX}/lib \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
