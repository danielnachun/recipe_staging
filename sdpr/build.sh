#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?gsl/include?$PREFIX/include?g" Makefile
sed -i "s?gsl/lib?$PREFIX/lib?g" Makefile
sed -i "s?MKL/lib?$PREFIX/lib?g" Makefile

if [[ ${target_platform} =~ .*osx.* ]]; then
    sed -i "s/--no-as-needed,//" Makefile
fi

make CC=${CXX}

mkdir -p ${PREFIX}/inb
install -m 755 SDPR ${PREFIX}/bin
