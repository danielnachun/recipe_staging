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

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

tar xvjf odig-${PKG_VERSION}.tbz
opam init --no-setup --disable-sandboxing
opam exec -- opam install ${PKG_NAME} -y --deps-only --no-depexts
opam switch default
eval $(opam env)

pushd odig-${PKG_VERSION}
    ocaml pkg/pkg.ml build
    install -m 755 _build/src/${PKG_NAME}_main.native ${PREFIX}/bin/${PKG_NAME}
    cp LICENSE.md ${SRC_DIR}
popd

mkdir -p license-files
${PREFIX}/bin/odig show license-files --lib-dir=${OPAMROOT}/default/lib --doc-dir=${OPAMROOT}/default/doc -l | cut -f 2 -d ' ' | \
    xargs -I % bash -c 'copy_license %'
