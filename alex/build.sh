#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PATH=${SRC_DIR}/binary/bin:${PATH}

cp src/Parser.y src/Parser.y.boot
cp src/Scan.x src/Scan.x.boot

cabal v2-install \
	alex \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${SRC_DIR}/binary/bin

happy -agc src/Parser.y -o src/Parser.hs
alex -g src/Scan.x -o src/Scan.hs

cabal v2-update
cabal --store-dir=${SRC_DIR}/.cabal v2-install \
    --extra-lib-dirs=${PREFIX}/lib \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
