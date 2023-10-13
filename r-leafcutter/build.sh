#!/bin/bash

export DISABLE_AUTOBREW=1
sed -i 's/-DBOOST_DISABLE_ASSERTS/-DBOOST_DISABLE_ASSERTS -D_REENTRANT/' leafcutter/src/Makevars

# shellcheck disable=SC2086
${R} CMD INSTALL --build leafcutter ${R_ARGS}

pushd clustering
    chmod -R +x *.py
    chmod -R +x *.R
    cp -r *.py ${PREFIX}/bin
    cp -r *.R ${PREFIX}/bin
popd

pushd scripts
    chmod -R +x *.py
    chmod -R +x *.R
    chmod -R +x *.pl
    cp -r *.py ${PREFIX}/bin
    cp -r *.R ${PREFIX}/bin
    cp -r *.pl ${PREFIX}/bin
popd
