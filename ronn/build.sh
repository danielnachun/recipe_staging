#!/usr/bin/env bash

export GEM_HOME=${PREFIX}/libexec/ronn
gem build ronn.gemspec
gem install ronn-${PKG_VERSION}.gem
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/share/man/man7

cat << EOF > ${PREFIX}/bin/ronn
    #!/bin/sh
    GEM_HOME="${PREFIX}/libexec/ronn" exec "${PREFIX}/libexec/ronn/bin" "$@"
EOF

install -m 644 man/ronn.1 ${PREFIX}/share/man/man1/ronn.1
install -m 644 man/ronn-format.7 ${PREFIX}/share/man/man7/ronn-format.7
