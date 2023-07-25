#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export OPAMROOT=${SRC_DIR}/.opam
export OPAMYES=1
export OPAMDOWNLOADJOBS=${CPU_COUNT}
export OPAMJOBS=${CPU_COUNT}

opam init --no-setup --disable-sandboxing
opam exec -- opam install ocamlformat -y --deps-only --no-depexts
opam exec -- make exe

mkdir -p ${PREFIX}/bin
install -m 755 _build/default/bin/ocamlformat/main.exe ${PREFIX}/bin/ocamlformat
install -m 755 _build/default/bin/ocamlformat/main.exe ${PREFIX}/bin/ocamlformat-rpc
