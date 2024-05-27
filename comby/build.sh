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
export OPAMDOWNLOADJOBS=1
export OPAMJOBS=1

opam init --no-setup --disable-sandboxing
opam exec -- opam install . --deps-only -y --no-depexts -vvv

export LIBRARY_PATH="${OPAMROOT}/default/lib/hack_parallel"
opam exec -- make release

mkdir -p ${PREFIX}/bin
install -m 755 _build/default/src/main.exe ${PREFIX}/bin/comby

opam switch default
eval $(opam env)
mkdir -p license-files
odig show license-files --lib-dir=${OPAMROOT}/default/lib --doc-dir=${OPAMROOT}/default/doc -l | cut -f 2 -d ' ' | \
    xargs -I % bash -c 'copy_license %'
