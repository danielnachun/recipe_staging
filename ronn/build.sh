#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies ronn-${PKG_VERSION}.gem --bindir=${PREFIX}/bin
gem unpack ronn-${PKG_VERSION}.gem

mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/share/man/man7
ln -sf ${PREFIX}/share/rubygems/ronn-${PKG_VERSION}/man/man1/ronn.1 ${PREFIX}/share/man/man1
ln -sf ${PREFIX}/share/rubygems/ronn-${PKG_VERSION}/man/man7/ronn.7 ${PREFIX}/share/man/man7

cat << EOF > ${PREFIX}/etc/conda/activate.d/activate_ronn.sh
#!/bin/sh
GEM_HOME="${PREFIX}/share/rubygems"
EOF

cat << EOF > ${PREFIX}/etc/conda/deactivate.d/deactivate_ronn.sh
#!/bin/sh
unset GEM_HOME
EOF
