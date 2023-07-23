#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make install PREFIX=${PREFIX}
