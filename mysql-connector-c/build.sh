#!/bin/bash

# Required so that `mysql_config --libs` doesn't have missing library references
# xref: https://gitweb.gentoo.org/repo/gentoo.git/commit/dev-db/mysql-connector-c?id=035441b4c80a3d9b8e79f28a98523488d69f75bb
sed -i -e 's/CLIENT_LIBS/CONFIG_CLIENT_LIBS/' scripts/CMakeLists.txt

if [[ $target_platform =~ linux.* ]]; then
  export LDFLAGS="$LDFLAGS -Wl,-rpath-link,$PREFIX/lib"
fi

mkdir build
pushd build

# Set INSTALL_DOCREADMEDIR to a junk path to avoid installing the README into PREFIX
cmake  -G"$CMAKE_GENERATOR" \
       -DWITH_SSL=system \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_PREFIX_PATH=$PREFIX \
       -DCMAKE_INSTALL_PREFIX=$PREFIX \
       -DSHARED_LIB_PATCH_VERSION="0" \
       -DLIBMYSQL_OS_OUTPUT_NAME=mysqlclient \
       -DINSTALL_DOCREADMEDIR="${PWD}/junk" \
       -DINSTALL_DOCDIR="${PWD}/junk" \
       ..

make -j${CPU_COUNT} ${VERBOSE_AT}
make install

popd
