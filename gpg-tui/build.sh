#!/usr/bin/env bash

cargo install --locked --root ${PREFIX} --path .

export OUT_DIR=${SRC_DIR}
gpg-tui-completions
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
mkdir -p ${PREFIX}/share/zsh/site-functions
install -m 644 ${PKG_NAME}.bash ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
install -m 644 ${PKG_NAME}.fish ${PREFIX}/share/fish/vendor_completions.d/${PKG_NAME}.fish
install -m 644 _${PKG_NAME} ${PREFIX}/share/zsh/site-functions/_${PKG_NAME}

# strip debug symbols
"$STRIP" "$PREFIX/bin/${PKG_NAME}"

# remove extra build file
rm -rf ${PREFIX}/.crates*
