#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

${SRC_DIR}/cabal v2-update
${SRC_DIR}/cabal v2-install \
    --extra-lib-dirs=${PREFIX}/lib \
    --constraint "lukko -ofd-locking" \
	--gcc-options="-I${PREFIX}/include -L${PREFIX}/lib" \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin

mkdir -p ${PREFIX}/etc/bash_completion.d
install -m 644 bash-completion/cabal ${PREFIX}/etc/bash_completion.d/cabal
