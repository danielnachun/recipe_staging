#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/include
install -m 644 dr_wav.h ${PREFIX}/include/dr_wav.h
