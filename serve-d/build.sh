#!/usr/bin/env bash 

set -o xtrace -o nounset -o pipefail -o errexit

dub upgrade
dub build --build=release --compiler=ldc2

mkdir -p ${PREFIX}/bin
install -m 755 serve-d ${PREFIX}/bin
