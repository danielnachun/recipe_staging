#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
if [ `uname` == Darwin ] ; then
    extra_config_options="LDFLAGS=-Wl,-headerpad_max_install_names"
fi

export CXXFLAGS="${CXXFLAGS} -Wno-register"
export CFLAGS="${CFLAGS} -Wno-int-conversion -Wno-implicit-function-declaration"

## Configure and make
./configure --prefix=$PREFIX \
            --with-kinwalker \
            --with-cluster \
            --disable-lto \
            --without-doc \
            --without-tutorial \
            --without-tutorial-pdf \
            --without-cla \
            --without-rnaxplorer \
            ${extra_config_options} \
            && \
make -j${CPU_COUNT}

## Install
make install
