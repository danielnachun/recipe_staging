#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --locked --root ${PREFIX}/libexec/${PKG_NAME} --path helix-term

rm -rf runtime/grammars/sources
cp -r runtime ${PREFIX}/libexec/${PKG_NAME}

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/hx <<EOF
        #!/usr/bin/env bash
        HELIX_RUNTIME="${PREFIX}/libexec/${PKG_NAME}/runtime" exec "${PREFIX}/libexec/${PKG_NAME}/bin/hx" "\$@"
EOF

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 contrib/completion/hx.bash ${PREFIX}/etc/bash_completion.d/hx
install -m 644 contrib/completion/hx.fish ${PREFIX}/share/fish/vendor_completions.d/hx.fish
install -m 644 contrib/completion/hx.zsh ${PREFIX}/share/zsh/site-functions/_hx

# strip debug symbols
"$STRIP" "$PREFIX/libexec/${PKG_NAME}/bin/hx"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
