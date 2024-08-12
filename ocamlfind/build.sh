#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit


copy_license() {
    license_file=$1
    license_file_dirname=$(basename $(dirname ${license_file}))
    mkdir -p license-files/${license_file_dirname}
    cp ${license_file} license-files/${license_file_dirname}
}

export -f copy_license

export OPAMROOT=${SRC_DIR}/.opam
export OPAMYES=1
export OPAMDOWNLOADJOBS=${CPU_COUNT}
export OPAMJOBS=${CPU_COUNT}

opam init --no-setup --disable-sandboxing
opam exec -- opam install ocamlformat -y --deps-only --no-depexts
opam exec -- ./configure \
    -bindir ${PREFIX}/bin
opam exec -- make all
opam exec -- make install
