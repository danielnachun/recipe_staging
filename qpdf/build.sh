#!/bin/bash

cmake -S . -B build \
    -DUSE_IMPLICIT_CRYPTO=0 \
    -DREQUIRE_CRYPTO_OPENSSL=1 \
    ${CMAKE_ARGS}
cmake --build build
cmake --install build

