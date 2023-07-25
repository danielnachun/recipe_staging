#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export OPAMROOT=${SRC_DIR}/.opam
export OPAMYES=1
export OPAMDOWNLOADJOBS=${CPU_COUNT}
export OPAMJOBS=${CPU_COUNT}

opam init --no-setup --disable-sandboxing
opam exec -- opam install . --deps-only -y --no-depexts
opam exec -- make install

mkdir -p ${PREFIX}/bin
install -m 755 _build/default/ocaml-lsp-server/bin/main.exe ${PREFIX}/bin/ocamllsp
