#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin 
install -m 755 gcta_nr_robust ${PREFIX}/bin
