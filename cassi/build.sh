#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
${CXX} ${CXXFLAGS} ${LDFLAGS} *.cpp -o ${PREFIX}/bin/cassi
