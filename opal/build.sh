#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

install -m 755 opal ${PREFIX}/libexec/${PKG_NAME}
install -m 644 Opal.jar ${PREFIX}/libexec/${PKG_NAME}

sed -i 's?#!/usr/bin/perl?#!/usr/bin/env perl?' predict_structure.pl
install -m 755 predict_structure.pl ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/${PKG_NAME}/opal ${PREFIX}/bin
