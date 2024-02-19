#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == "linux-64" ]]; then
  export CFLAGS="${CFLAGS} -lrt"
  export CXXFLAGS="${CXXFLAGS} -lrt"
fi

./autogen.sh
./configure --prefix=$PREFIX
make -j${CPU_COUNT}
make install
