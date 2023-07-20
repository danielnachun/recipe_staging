#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --with-idn \
    --disable-ifconfig \
    --disable-logger \
    --disable-ping \
    --disable-traceroute \
    --disable-whois

make SUIDMODE= install
