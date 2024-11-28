#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ $target_platform =~ .*osx.* ]]; then
    LDFLAGS="-liconv"
fi

autoreconf --force --install --verbose
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} 
make install
