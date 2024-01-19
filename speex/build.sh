#!/bin/bash

EXTRA_FLAGS=""
if [[ ${target_platform} == "linux-64" ]]; then
  EXTRA_FLAGS="--enable-sse"
fi

./configure --prefix=${PREFIX} $EXTRA_FLAGS
make
make check
make install
