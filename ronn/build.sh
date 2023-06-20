#!/usr/bin/env bash

export GEM_HOME=${PREFIX}/libexec/ronn
gem install -N -l -V --ignore-dependencies ronn-${PKG_VERSION}.gem
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/share/man/man7

cat << EOF > ${PREFIX}/etc/conda/activate.d/activate_ronn.sh
#!/bin/sh
GEM_HOME="${PREFIX}/libexec/ronn"
EOF

cat << EOF > ${PREFIX}/etc/conda/deactivate.d/deactivate_ronn.sh
#!/bin/sh
unset GEM_HOME
EOF

cat << EOF > ${PREFIX}/bin/ronn
#!/bin/sh
exec "${PREFIX}/libexec/ronn/bin/ronn" "$@"
EOF

install -m 644 man/ronn.1 ${PREFIX}/share/man/man1/ronn.1
install -m 644 man/ronn-format.7 ${PREFIX}/share/man/man7/ronn-format.7
