#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
ldmd2 -od. -ofdtools-rdmd rdmd.d
install -m 755 dtools-rdmd ${PREFIX}/bin

for tool in DustMite/dustmite ddemangle catdoc detab tolf dget; do
    ./dtools-rdmd --compiler=ldmd2 --build-only -od. -ofdtools-`basename ${tool}` ${tool}.d
    install -m 755 dtools-`basename ${tool}` ${PREFIX}/bin
done

ln -sf ${PREFIX}/bin/dtools-rdmd ${PREFIX}/bin/rdmd
ln -sf ${PREFIX}/bin/dtools-dustmite ${PREFIX}/bin/dustmite
ln -sf ${PREFIX}/bin/dtools-ddemangle ${PREFIX}/bin/ddemangle
