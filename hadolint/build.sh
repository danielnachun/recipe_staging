#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cabal v2-update
cabal --store-dir=${SRC_DIR}/.cabal v2-install \
    --extra-lib-dirs=${PREFIX}/lib \
    --allow-newer=base,Cabal,deepseq \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
