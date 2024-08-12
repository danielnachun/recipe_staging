#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

echo "packages:" > cabal.project
yq '(.packages)' stack.yaml | sed 's/- /  .\//' >> cabal.project

export CABAL_DIR=${SRC_DIR}/.cabal
cabal v2-update
cabal v2-install unison-cli-main \
    --constraint "lsp<2.4" \
    --allow-newer=containers,text \
    --extra-lib-dirs=${PREFIX}/lib \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
cabal-plan license-report --licensedir=${SRC_DIR}/license-files exe:${PKG_NAME}
