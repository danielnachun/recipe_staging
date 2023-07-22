#!/bin/bash

make
install -Dm 755 ${PKG_NAME} ${PREFIX}/bin/${PKG_NAME}
