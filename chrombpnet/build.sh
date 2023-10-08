#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/__main_-/__main__' chrombpnet/CHROMBPNET.py
${PYTHON} -m pip install . -vv
