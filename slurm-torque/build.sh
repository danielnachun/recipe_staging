#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

install -Dd ${PREFIX}/bin
cp -r ${SRC_DIR}/contribs/torque/* ${PREFIX}/bin
