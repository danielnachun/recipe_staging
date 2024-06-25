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

opam init --no-setup --disable-sandboxing
opam exec -- opam install ${PKG_NAME} -y --deps-only --no-depexts
opam switch default
eval $(opam env)
dune build

mkdir -p ${PREFIX}/bin
install -m 755 _build/default/src/main/main.exe ${PREFIX}/bin/earlybird

mkdir -p license-files
odig show license-files --lib-dir=${OPAMROOT}/default/lib --doc-dir=${OPAMROOT}/default/doc -l | cut -f 2 -d ' ' | \
    xargs -I % bash -c 'copy_license %'
