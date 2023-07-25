#!/bin/bash

dub upgrade
dub build --build=release --compiler=ldc2

install -Dd ${PREFIX}/bin
install -Dm 755 serve-d ${PREFIX}/bin
