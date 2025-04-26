#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/\.so/$(SHLIB_EXT)/' Makefile
if [[ ${target_platform} =~ .*osx.* ]]; then
    sed -i 's/-soname/-install_name/' Makefile
fi
make install CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" PREFIX="${PREFIX}"
