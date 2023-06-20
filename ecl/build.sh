#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./src/libffi
cp $BUILD_PREFIX/share/gnuconfig/config.* ./src/bdwgc
cp $BUILD_PREFIX/share/gnuconfig/config.* ./src/bdwgc/libatomic_ops
cp $BUILD_PREFIX/share/gnuconfig/config.* ./src/gmp
cp $BUILD_PREFIX/share/gnuconfig/config.* ./src

export CC=$(basename $CC)
export AR=$(basename $AR)
export RANLIB=$(basename $RANLIB)
export CFLAGS="-g $CFLAGS"

if [[ "$target_platform" == osx-* ]]; then
    export CFLAGS="-Wno-unknown-attributes $CFLAGS"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  export ECL_TO_RUN=$BUILD_PREFIX/bin/ecl
  if [[ "$target_platform" == "osx-arm64" ]]; then
    cp src/util/iOS-arm64.cross_config cross_config
    cp src/util/iOS-arm64.cross_config src/cross_config
  fi
fi

chmod +x configure
./configure \
        --prefix="$PREFIX" \
        --libdir="$PREFIX/lib" \
        --with-gmp-prefix="$PREFIX" \
        --disable-threads \
        --enable-unicode=yes

# Before running make we touch build/TAGS so its building process is never triggered
touch build/TAGS

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make check
fi
make install

ln -s $PREFIX/lib/ecl-* $PREFIX/lib/ecl
ln -s $PREFIX/include/ecl $PREFIX/lib/ecl/ecl

cat $SRC_DIR/build/cmp/cmpdefs.lsP
mkdir -p $PREFIX/share/ecl
sed "s/defvar/defparameter/g" $SRC_DIR/build/cmp/cmpdefs.lsp > $PREFIX/share/ecl/cmpdefs.lsp
