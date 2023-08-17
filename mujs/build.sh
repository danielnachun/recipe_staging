#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/-l:\$/-l$/g' Makefile
make prefix=${PREFIX} static libmujs=mujs
make prefix=${PREFIX} shared libmujs=mujs
make prefix=${PREFIX} release libmujs=mujs
make prefix=${PREFIX} install
make prefix=${PREFIX} install-shared
