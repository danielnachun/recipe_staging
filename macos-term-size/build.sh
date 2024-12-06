#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

${CC} -std=c99 term-size.c -o term-size

mkdir -p ${PREFIX}/bin
install -m 755 term-size ${PREFIX}/bin
