#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}/bin
gem install -N -l -V --ignore-dependencies --bindir "${PREFIX}/libexec/${PKG_NAME}/bin" ${PKG_NAME}-${PKG_VERSION}.gem
gem unpack ${PKG_NAME}-${PKG_VERSION}.gem

mkdir -p ${PREFIX}/bin
sed -i "s?\$bindir?${PREFIX}/bin?g" ${PREFIX}/libexec/${PKG_NAME}/bin/${PKG_NAME}
cat << EOF > ${PREFIX}/bin/${PKG_NAME}
#!/bin/sh
GEM_HOME="${PREFIX}/share/rubygems" exec "${PREFIX}/libexec/${PKG_NAME}/bin/${PKG_NAME}" "\$@"
EOF

sed -i "s?\$bindir?${PREFIX}/bin?g" ${PREFIX}/libexec/${PKG_NAME}/bin/code_climate_reek
cat << EOF > ${PREFIX}/bin/code_climate_reek
#!/bin/sh
GEM_HOME="${PREFIX}/share/rubygems" exec "${PREFIX}/libexec/${PKG_NAME}/bin/code_climate_reek" "\$@"
EOF
