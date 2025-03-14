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
opam exec -- make exe

mkdir -p ${PREFIX}/bin
install -m 755 _build/default/bin/ocamlformat/main.exe ${PREFIX}/bin/ocamlformat
install -m 755 _build/default/bin/ocamlformat/main.exe ${PREFIX}/bin/ocamlformat-rpc

mkdir -p license-files
odig show license-files --lib-dir=${OPAMROOT}/default/lib --doc-dir=${OPAMROOT}/default/doc -l | cut -f 2 -d ' ' | \
    xargs -I % bash -c 'copy_license %'
