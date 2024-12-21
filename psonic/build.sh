#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

install -m 755 pSONIC.py ${PREFIX}/bin
