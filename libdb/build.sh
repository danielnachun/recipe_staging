#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./dist
cp $BUILD_PREFIX/share/gnuconfig/config.* ./lang/sql/odbc
cp $BUILD_PREFIX/share/gnuconfig/config.* ./lang/sql/jdbc
cp $BUILD_PREFIX/share/gnuconfig/config.* ./lang/sql/sqlite
cp $BUILD_PREFIX/share/gnuconfig/config.* ./lang/sql/sqlite/autoconf

if [[ $(uname) == Darwin ]]; then
  export CC=clang
  export CXX=clang++
  export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -headerpad_max_install_names $LDFLAGS"
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
  export MACOSX_DEPLOYMENT_TARGET="11.0"
  export CXXFLAGS="-stdlib=libc++ $CXXFLAGS -DHAVE_PTHREAD_TLS"
fi

cd build_unix
../dist/configure --prefix=$PREFIX \
                  --enable-shared \
                  --disable-static \
                  --enable-cxx \
                  --enable-stl

make -j$CPU_COUNT
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check -j$CPU_COUNT
fi
make install -j$CPU_COUNT

cd $PREFIX
find . -type f -name "*.la" -exec rm -rf '{}' \; -print
