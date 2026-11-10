#!/bin/bash

sed -i 's/mr\.ash/mr.ashr/g' DESCRIPTION
sed -i 's/mr\.ash/mr.ashr/g' NAMESPACE
sed -i 's/@importFrom mr\.ash/@importFrom mr.ashr/g' NAMESPACE

export DISABLE_AUTOBREW=1
R CMD INSTALL --build . ${R_ARGS}
