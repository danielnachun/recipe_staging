#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*linux.* ]]; then
    ./configure --prefix=$PREFIX  --mandir=${PREFIX}/share/man
    make lib-ext 
    make 
    make install
else
    mkdir -p ${PREFIX}/bin
    install -m 755 opam ${PREFIX}/bin
fi
