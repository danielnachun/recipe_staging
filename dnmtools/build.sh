#!/bin/bash

rm -rf src/abismal/src/popcnt.hpp
ln -sf ${PREFIX}/include/popcnt.hpp src/abismal/src

./configure --prefix=$PREFIX
make CXXFLAGS="-O3 -DNDEBUG -D_LIBCPP_DISABLE_AVAILABILITY"
make install
