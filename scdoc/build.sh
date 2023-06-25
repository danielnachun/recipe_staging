#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="-Wno-strict-prototypes"
make LDFLAGS= PREFIX=${PREFIX}
make install PREFIX=${PREFIX}
