#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make release shared
make prefix=${PREFIX} install
make prefix=${PREFIX} install-shared
