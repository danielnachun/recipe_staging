#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

copy_license() {
    license_file=$1
    license_file_dirname=$(basename $(dirname ${license_file}))
    mkdir -p ${SRC_DIR}/license-files/${license_file_dirname}
    cp ${license_file} ${SRC_DIR}/license-files/${license_file_dirname}
}

export -f copy_license

export OPAMROOT=${SRC_DIR}/.opam
export OPAMYES=1
export OPAMDOWNLOADJOBS=${CPU_COUNT}
export OPAMJOBS=${CPU_COUNT}

opam init --no-setup --disable-sandboxing
opam exec -- opam install . -y --deps-only --no-depexts --with-test
opam exec -- dune build --profile release @install
opam exec -- dune install --prefix ${PREFIX}

mkdir -p license-files
odig show license-files --lib-dir=${OPAMROOT}/default/lib --doc-dir=${OPAMROOT}/default/doc -l | cut -f 2 -d ' ' | \
    xargs -I % bash -c 'copy_license %'

case ${target_platform} in
    linux-64)
        os_path="linux" ;;
    linux-aarch64)
        os_path="linuxarm64" ;;
    osx-64)
        os_path="darwin" ;;
    osx-arm64)
        os_path="darwinarm64" ;;
esac
mkdir -p ${PREFIX}/lib/node_modules/${PKG_NAME}/analysis_binaries/${os_path}
ln -sf ${PREFIX}/bin/rescript-editor-analysis.exe ${PREFIX}/lib/node_modules/${PKG_NAME}/analysis_binaries/${os_path}

npm install
npm run compile

cd server
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
     ${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt
