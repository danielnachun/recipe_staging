#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export DISABLE_AUTOBREW=1

# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
