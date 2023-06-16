#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --sysconfdir=${PREFIX}/etc \
    --with-packager=conda-forge \
    --with-package-version=${PKG_VERSION}
make install
make test
