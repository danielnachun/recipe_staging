#!/bin/bash

npm pack --ignore-scripts

npm install -ddd \
    --global \
    --build-from-source \
    --prefix=${PREFIX}/libexec/${PKG_NAME} \
    ${PKG_NAME}-${PKG_VERSION}.tgz

install -Dd ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/vim-language-server ${PREFIX}/bin
