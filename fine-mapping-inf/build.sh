#!/bin/bash

sed -i '1 i\#!/usr/bin/env python3' run_fine_mapping.py
pushd susieinf
$PYTHON setup.py bdist_wheel
$PYTHON -m pip install .
popd

pushd finemapinf
$PYTHON setup.py bdist_wheel
$PYTHON -m pip install .
popd

mkdir -p ${PREFIX}/bin
install -m 755 run_fine_mapping.py ${PREFIX}/bin
