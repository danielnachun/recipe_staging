#!/bin/bash

if [[ ${target_platform} == "osx-arm64" ]]; then
    export EXTRA_FLAGS="POPCNT_CAPABILITY=0"
else
    export EXTRA_FLAGS=""
fi

make prefix="${PREFIX}" ${EXTRA_FLAGS} install

cp -r scripts "${PREFIX}/bin/"
