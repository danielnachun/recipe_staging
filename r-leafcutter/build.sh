#!/bin/bash

export DISABLE_AUTOBREW=1
sed -i 's/-DBOOST_DISABLE_ASSERTS/-DBOOST_DISABLE_ASSERTS -D_REENTRANT/' leafcutter/src/Makevars

# shellcheck disable=SC2086
${R} CMD INSTALL --build leafcutter ${R_ARGS}
