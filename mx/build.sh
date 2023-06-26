#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/etc/bash_completion.d
cp -r * ${PREFIX}/libexec/${PKG_NAME}

cat << EOF > ${PREFIX}/bin/${PKG_NAME}
#!/bin/sh
MX_PYTHON=${PREFIX}/bin/python3 ${PREFIX}/libexec/${PKG_NAME}/mx "\$@"
EOF

install -m 644 ${PREFIX}/libexec/${PKG_NAME}/bash_completion/${PKG_NAME} ${PREFIX}/etc/bash_completion.d/${PKG_NAME}
