#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}/bin
gem build ${PKG_NAME}.gemspec
gem install -N -l -V --ignore-dependencies --bindir "${PREFIX}/libexec/${PKG_NAME}/bin" ${PKG_NAME}-${PKG_VERSION}.gem

mkdir -p ${PREFIX}/bin
sed -i "s?\$bindir?${PREFIX}/bin?g" ${PREFIX}/libexec/${PKG_NAME}/bin/ascli
sed -i "s?\$bindir?${PREFIX}/bin?g" ${PREFIX}/libexec/${PKG_NAME}/bin/asession

cat << EOF > ${PREFIX}/bin/ascli
#!/bin/sh
GEM_HOME="${PREFIX}/share/rubygems" exec "${PREFIX}/libexec/${PKG_NAME}/bin/ascli" "\$@"
EOF

cat << EOF > ${PREFIX}/bin/asession
#!/bin/sh
GEM_HOME="${PREFIX}/share/rubygems" exec "${PREFIX}/libexec/${PKG_NAME}/bin/asession" "\$@"
EOF
