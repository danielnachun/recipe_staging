#!/bin/bash
set -o errexit -o pipefail
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P"
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build .
