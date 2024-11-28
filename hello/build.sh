#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ $target_platform =~ .*osx.* ]]; then
    LDFLAGS="-liconv"
fi

sed -i 's/AM_GNU_GETTEXT_VERSION/AM_GNU_GETTEXT_REQUIRE_VERSION/' configure.ac

autoreconf --force --install --verbose
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
