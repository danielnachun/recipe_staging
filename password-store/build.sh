#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# make test
make WITH_ALLCOMP=yes install
