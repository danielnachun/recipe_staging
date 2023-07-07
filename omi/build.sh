#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export OMI_BUILDVERSION_MAJOR=$(echo ${PKG_VERSION} | cut -d '.' -f 1)
export OMI_BUILDVERSION_MINOR=$(echo ${PKG_VERSION} | cut -d '.' -f 2)
export OMI_BUILDVERSION_PATCH=$(echo ${PKG_VERSION} | cut -d '.' -f 3 | sed 's/_.*$//g')
export OMI_BUILDVERSION_BUILDNR=${PKG_BUILDNUM}

sed -i "s/-Dmacos/-Dmacos=macos/" Unix/buildtool
sed -i "s/MI_Server/extern MI_Server/" Unix/provmgr/indicationSchema.c
sed -i "s/MI_Server/extern MI_Server/" Unix/omi_error/schema.c
pushd Unix
    ./configure --prefix=${PREFIX} --openssl=${PREFIX}/bin/openssl
    if [[ ${target_platform} =~ .*linux.* ]]; then
        make PALLIBS="pal stdc++ gmp" CXX="${CXX} -std=c++11"
    else
        make CXX="${CXX} -std=c++11"
    fi
popd

mkdir -p ${PREFIX}/lib
cp -r Unix/output/lib/*${SHLIB_EXT} ${PREFIX}/lib
