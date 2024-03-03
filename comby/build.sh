#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export OPAMROOT=${SRC_DIR}/.opam
export OPAMYES=1
export OPAMDOWNLOADJOBS=1
export OPAMJOBS=1

opam init --no-setup --disable-sandboxing
opam exec -- opam install . --deps-only -y --no-depexts -vvv

export LIBRARY_PATH="${OPAMROOT}/default/lib/hack_parallel"
opam exec -- make release

mkdir -p ${PREFIX}/bin
install -m 755 _build/default/src/main.exe ${PREFIX}/bin/comby
