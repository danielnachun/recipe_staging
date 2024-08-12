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
opam exec -- make -f configure.make all \
    OCAMLBUILD_PREFIX=${PREFIX} \
    OCAMLBUILD_BINDIR=${PREFIX}/bin \
    OCAMLBUILD_LIBDIR=${PREFIX}/lib/ocaml \
    OCAMLBUILD_MANDIR=${PREFIX}/share/man \
    OCAML_NATIVE=true
opam exec -- make check-if-preinstalled all install-bin install-lib install-man

mkdir -p license-files
odig show license-files --lib-dir=${OPAMROOT}/default/lib --doc-dir=${OPAMROOT}/default/doc -l | cut -f 2 -d ' ' | \
    xargs -I % bash -c 'copy_license %'
