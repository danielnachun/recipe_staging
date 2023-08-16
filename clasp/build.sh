#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./koga --bin-path=${PREFIX}/bin \
    --lib-path=${PREFIX}/lib/clasp \
    --share-path=${PREFIX}/share/clasp \
    --ldflags="-Wl,-rpath,${PREFIX}/lib" \
    --cxxflags="-D_LIBCPP_DISABLE_AVAILABILITY"
sed -i 's/NIL//g' build/build.ninja
ninja -j 8 -C build
ninja -j 8 -C build install
