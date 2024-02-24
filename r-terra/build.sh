#!/bin/bash
export DISABLE_AUTOBREW=1

# workarounds:
# 1) conda-forge/r-base-feedstock#163
# 2) tolerate older osx sdk
export PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P -D_LIBCPP_DISABLE_AVAILABILITY ${PKG_CPPFLAGS}"

sed -i.bak 's/${PROJ_LIBS}/${PROJ_LIBS} ${LDFLAGS}/g' configure
sed -i.bak 's/${LIBS}/${LIBS} ${LDFLAGS}/g' configure

mv DESCRIPTION DESCRIPTION.old
grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION
${R} CMD INSTALL --build . ${R_ARGS}
