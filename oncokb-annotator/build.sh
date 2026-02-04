#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
chmod +x ${SRC_DIR}/*.py
sed -i 's|bin/python|bin/env python3|' ${SRC_DIR}/*.py
cp ${SRC_DIR}/*.py ${PREFIX}/bin
