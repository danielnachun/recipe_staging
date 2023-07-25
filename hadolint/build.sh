#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cabal v2-update
cabal v2-install -v3 \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin
