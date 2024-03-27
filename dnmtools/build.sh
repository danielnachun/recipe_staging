#!/bin/bash

./configure --prefix=$PREFIX
make CXXFLAGS="-O3 -DNDEBUG -D_LIBCPP_DISABLE_AVAILABILITY -D_MM_HINT_T0=1"
make install
