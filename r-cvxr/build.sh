#!/bin/bash
export DISABLE_AUTOBREW=1
sed -ie 's/PKG_CPPFLAGS =/PKG_CPPFLAGS = -DHAVE_WORKING_LOG1P/' src/Makevars
${R} CMD INSTALL --build . ${R_ARGS}
