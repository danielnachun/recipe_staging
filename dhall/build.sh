#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cabal v2-update
cabal --store-dir=${SRC_DIR}/.cabal v2-install all \
    --minimize-conflict-set \
    --allow-newer=base,bytestring,text,aeson,hnix,free,algebraic-graphs \
    --extra-lib-dirs=${PREFIX}/lib \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin

echo "package *" >> cabal.project
echo "   ghc-options: -XDuplicateRecordFields" >> cabal.project

mkdir -p ${PREFIX}/share/man/man1
install -m 644 dhall/man/dhall.1 ${PREFIX}/share/man/man1/dhall.1
