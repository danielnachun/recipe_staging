#!/bin/bash

rm -rf src/abismal/src/popcnt.hpp
cp ${PREFIX}/include/libpopcnt.h src/abismal/src/popcnt.hpp

./configure --prefix=$PREFIX
make CXXFLAGS="-O3 -DNDEBUG -D_LIBCPP_DISABLE_AVAILABILITY"
make install
