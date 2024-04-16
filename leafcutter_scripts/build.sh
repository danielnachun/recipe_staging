#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pushd clustering
    chmod -R +x *.py
    cp -r *.py ${PREFIX}/bin
popd

pushd scripts
    chmod -R +x *.py
    chmod -R +x *.pl
    cp -r *.py ${PREFIX}/bin
    cp -r *.pl ${PREFIX}/bin
popd
