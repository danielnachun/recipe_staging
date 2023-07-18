#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make doc/man
make install DESTDIR=${PREFIX}
make installman DESTDIR=${PREFIX}
