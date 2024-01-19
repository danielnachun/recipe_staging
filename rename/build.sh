#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p $PREFIX/bin

chmod +x $SRC_DIR/rename
mv $SRC_DIR/rename $PREFIX/bin/rename
