#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

#sed -i 's/68.0.1/68.2.1/' Cargo.lock
#sed -i 's/5c6be7c4f985508684e54f18dd37f71e66f3e1ad9318336a520d7e42f0d3ea8e/195ebddbb56740be48042ca117b8fb6e0d99fe392191a9362d82f5f69e510379/' Cargo.lock
#sed -i 's/1.0.45/1.0.67/' Cargo.lock
#sed -i 's/4fc9a35e1f4290eb9e5fc54ba6cf40671ed2a2514c3eeb2b2a908dda2ea5a1be/e3c69b077ad434294d3ce9f1f6143a2a4b89a8a2d54ef813d85003a4fd1137fd/' Cargo.lock

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX} --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
