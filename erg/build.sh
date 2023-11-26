#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
export HOME=${SRC_DIR}
cargo install --features full --locked --root ${PREFIX}/libexec/${PKG_NAME} --path .

mkdir -p ${PREFIX}/share/${PKG_NAME}
cp -R .erg/* ${PREFIX}/share/${PKG_NAME}

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
ERG_PATH=${PREFIX}/share/${PKG_NAME} exec ${PREFIX}/libexec/${PKG_NAME}/bin/${PKG_NAME} "\$@"
EOF

# strip debug symbols
"$STRIP" "$PREFIX/libexec/${PKG_NAME}/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
