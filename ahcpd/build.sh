#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's?man/man8/ahcpd.8?share/man/man8/ahcpd.8?g' Makefile
if [[ $target_platform =~ .*osx.* ]]; then
    make LDLIBS=
else
    make 
fi
make install PREFIX= TARGET=${PREFIX}
