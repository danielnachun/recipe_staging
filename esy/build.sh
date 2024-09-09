#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit


copy_license() {
    license_file=$1
    license_file_dirname=$(basename $(dirname ${license_file}))
    mkdir -p license-files/${license_file_dirname}
    cp ${license_file} license-files/${license_file_dirname}
}

export -f copy_license

# Create wrappers around cc and c++ because they are hard-coded in bz2 dependency
if [[ ${target_platform} =~ .*linux.* ]]; then
mkdir -p ${SRC_DIR}/sbin
tee ${SRC_DIR}/sbin/cc << EOF
#!/bin/sh
exec \${CC} \${CFLAGS} \${LDFLAGS} \$@
EOF
chmod +x ${SRC_DIR}/sbin/cc

tee ${SRC_DIR}/sbin/c++ << EOF
#!/bin/sh
exec \${CXX} \${CXXFLAGS} \${LDFLAGS} \$@
EOF
chmod +x ${SRC_DIR}/sbin/c++
fi

export OPAMROOT=${SRC_DIR}/.opam
export OPAMYES=1
export OPAMDOWNLOADJOBS=${CPU_COUNT}
export OPAMJOBS=${CPU_COUNT}

opam init --no-setup --disable-sandboxing
export PATH="${SRC_DIR}/sbin:${PATH}"
opam exec -- opam install . -y --deps-only --no-depexts
opam exec -- dune build --only-packages=esy --profile release @install
opam exec -- dune install --prefix ${PREFIX}

mkdir -p license-files
odig show license-files --lib-dir=${OPAMROOT}/default/lib --doc-dir=${OPAMROOT}/default/doc -l | cut -f 2 -d ' ' | \
    xargs -I % bash -c 'copy_license %'
