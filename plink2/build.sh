#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's|-I/opt/homebrew/include -I/usr/local/include||g' Makefile
sed -i 's|-L/opt/homebrew/lib -L/usr/local/lib||g' Makefile

make CXX=${CXX} CC=${CC} CXXFLAGS="${CXXFLAGS}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
