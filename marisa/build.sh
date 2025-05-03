#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

case ${target_platform} in
    osx-64|linux-64)
        extra_configure_args="--enable-sse2" ;;
    *)
        extra_configure_args="" ;;
esac

export ACLOCAL_PATH=${PREFIX}/share/aclocal

autoreconf --force --install --verbose
./configure --disable-silent-rules \
    --disable-static \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    ${extra_configure_args}
make install
