#!/bin/bash

set -ex

export ANT_HOME="${PREFIX}"

for i in etc lib bin; do
  mkdir -p "${PREFIX}/$i"
done

if [[ "${target_platform}" == linux-* ]]; then
    ./build.sh install-lite
else
    # on osx, the build fails with chmod/permission errors without this
    # option, which has been renamed in source, but not in the docs, see
    # https://github.com/apache/ant/commit/c7d9b17b080fc5250fc05144322ecc3eef8a6e87
    ./build.sh install-lite -Dsetpermissions.fail=false
fi

# ensure that ANT_HOME is set correctly
mkdir -p $PREFIX/etc/conda/activate.d
echo 'export ANT_HOME_CONDA_BACKUP=$ANT_HOME' > "$PREFIX/etc/conda/activate.d/ant_home.sh"
echo 'export ANT_HOME=$CONDA_PREFIX' >> "$PREFIX/etc/conda/activate.d/ant_home.sh"
mkdir -p $PREFIX/etc/conda/deactivate.d
echo 'export ANT_HOME=$ANT_HOME_CONDA_BACKUP' > "$PREFIX/etc/conda/deactivate.d/ant_home.sh"
