#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cabal v2-update
cabal --store-dir=${SRC_DIR}/.cabal v2-install \
    --allow-newer=ghc-lib-parser,text,bytestring,aeson \
    --extra-lib-dirs=${PREFIX}/lib \
    --flags=+ghc-lib \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
