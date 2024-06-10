#!/bin/bash
set -o errexit -o pipefail

export CPPFLAGS="${CPPFLAGS} -Wl,-rpath,${PREFIX}/lib"
# This is just to get around a configure failure when trying to link to gdal.	  ${R} CMD INSTALL --build .
LIBS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
if [[ ${target_platform} == osx-* ]] || [[ ${target_platform} == linux-* ]]; then
  LIBRARY_PATH=${PREFIX}/lib
  export CXX="${CXX} --std=c++14 -Wl,-rpath,${PREFIX}/lib"
  export CC="${CC} -Wl,-rpath,${PREFIX}/lib"
fi

export DISABLE_AUTOBREW=1
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
${R} CMD INSTALL --build .
