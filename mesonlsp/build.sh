#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i '/Requires.private/d' ${PREFIX}/lib/pkgconfig/libarchive.pc
sed -i "s/'-Wl,-ld_classic'//" meson.build
sed -i 's/and !defined(__x86_64__)//g' src/polyfill/polyfill.hpp

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
if [[ ${target_platform} =~ .*linux.* ]]; then
    export CFLAGS="${CFLAGS} -pthread"
    export CXXFLAGS="${CXXFLAGS} -pthread"
fi

meson --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --buildtype=release \
    build
meson compile -C build -v
meson install -C build
