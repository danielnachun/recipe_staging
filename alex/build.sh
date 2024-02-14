#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PATH=${SRC_DIR}/binary/bin:${PATH}

cabal v2-update
cabal v2-install \
	alex \
    happy \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${SRC_DIR}/binary/bin

cd alex

happy -agc src/Parser.y -o src/Parser.hs
alex -g src/Scan.x -o src/Scan.hs

mv src/Parser.y src/Parser.y.boot
mv src/Scan.x src/Scan.x.boot

cabal --store-dir=${SRC_DIR}/.cabal v2-install \
    --extra-lib-dirs=${PREFIX}/lib \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
