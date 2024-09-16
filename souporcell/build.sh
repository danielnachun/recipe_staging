#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pushd souporcell
    cargo-bundle-licenses \
        --format yaml \
        --output THIRDPARTY.yml

    # build statically linked binary with Rust
    cargo install --no-track --locked --root ${PREFIX} --path .

    # strip debug symbols
    "$STRIP" "$PREFIX/bin/$PKG_NAME"
popd

pushd troublet
    cargo-bundle-licenses \
        --format yaml \
        --output THIRDPARTY.yml

    # build statically linked binary with Rust
    cargo install --no-track --locked --root ${PREFIX} --path .

    # strip debug symbols
    "$STRIP" "$PREFIX/bin/$PKG_NAME"
popd

mv ${PREFIX}/bin/souporcell ${PREFIX}/bin/souporcell-rs
install -m 755 consensus.py ${PREFIX}/bin/consensus
install -m 755 reformat-smartseq.py ${PREFIX}/bin/reformat-smartseq
install -m 755 renamer.py ${PREFIX}/bin/renamer
install -m 755 shared_samples.py ${PREFIX}/bin/shared_samples
install -m 755 souporcell.py ${PREFIX}/bin/souporcell
install -m 755 souporcell_pipeline.py ${PREFIX}/bin/souporcell_pipeline
