set -x
set -o xtrace

echo
echo
echo
echo ================================================================
env|sort
echo ================================================================
echo
echo
echo

if [[ $target_platform  == osx-64 ]]; then
  export NN_CXX_ORIG=$CXX
  export NN_CC_ORIG=$CC
  export CXX=$RECIPE_DIR/cxx_wrap.sh
  export CC=$RECIPE_DIR/cc_wrap.sh
  mkdir -p ~/.R
  echo CC=$RECIPE_DIR/cc_wrap.sh > ~/.R/Makevars
  echo CXX=$RECIPE_DIR/cxx_wrap.sh >> ~/.R/Makevars
  echo CXX17=$RECIPE_DIR/cxx_wrap.sh >> ~/.R/Makevars
fi

## Build a tarball and install from the tarball is the officially blessed way
## It has also respects the .Rbuildignore file allowing us to fine-tune
$R CMD build --no-manual --no-build-vignettes .
$R CMD INSTALL --configure-args=--with-tiledb=${CONDA_PREFIX} --install-tests --build tiledb_*.tar.gz ${R_ARGS}
