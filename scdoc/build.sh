#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make LDFLAGS= PREFIX=${PREFIX}
make install PREFIX=${PREFIX}
