#!/usr/bin/env bash

## These variables have to be set correctly.
## RSTUDIO_VERSION_SUFFIX will need to be updated here for every new version bump
export RSTUDIO_VERSION_MAJOR=$(echo ${PKG_VERSION} | cut -d. -f1)
export RSTUDIO_VERSION_MINOR=$(echo ${PKG_VERSION} | cut -d. -f2)
export RSTUDIO_VERSION_PATCH=$(echo ${PKG_VERSION} | cut -d. -f3)
export RSTUDIO_VERSION_SUFFIX=+$(echo ${PKG_BUILDNUM})
export GIT_COMMIT=a1fe401

export PACKAGE_OS=$(uname -om)

export BUILD_TYPE=Release
export RSTUDIO_TARGET=Server

export RSTUDIO_TOOLS_ROOT="${PREFIX}/opt/rstudio-tools/$(uname -m)"
mkdir -p $RSTUDIO_TOOLS_ROOT
export SOCI_LIBRARY_DIR=${PREFIX}/lib
export SOCI_DIR=$RSTUDIO_TOOLS_ROOT/soci
export SOCI_BIN_DIR=$SOCI_DIR/build
mkdir -p $SOCI_BIN_DIR
ln -s ${PREFIX}/* ${SOCI_BIN_DIR}
export SOCI_CORE_LIB=${PREFIX}/lib/libsoci_core.so
export SOCI_POSTGRESQL_LIB=${PREFIX}/lib/libsoci_postgresql.so
export SOCI_SQLITE_LIB=${PREFIX}/lib/libsoci_sqlite3.so
export RSTUDIO_DISABLE_CRASHPAD=1
export RSTUDIO_CRASHPAD_ENABLED=FALSE
export YAML_CPP_INCLUDE_DIR=${PREFIX}/include
export OPENSSL_ROOT_DIR=$PREFIX

sed -i 's/return afterResponse_;/return static_cast<bool>(afterResponse_);/g' src/cpp/core/json/JsonRpc.cpp

## Instead of installing dependencies as instructed by the upstream
## build documentation we create symlinks in the expected locations
## to the conda-forge equivalents
pushd dependencies/common
_pandocver=$(rg -o --pcre2 "(?<=PANDOC_VERSION=\").*(?=\"$)" install-pandoc)
_nodever=$(rg -o --pcre2 "(?<=RSTUDIO_INSTALLED_NODE_VERSION=\").*(?=\"$)" ../tools/rstudio-tools.sh)
install -d pandoc/${_pandocver}
install -d node
ln -sfT ${PREFIX}/bin/pandoc pandoc/${_pandocver}/pandoc
ln -sfT ${PREFIX} node/${_nodever}
ln -sfT ${PREFIX} node/${_nodever}-patched
ln -sfT ${PREFIX}/share/hunspell_dictionaries dictionaries
ln -sfT ${PREFIX}/lib/mathjax mathjax-27
popd

# Fix links for src/cpp/session/CMakeLists.txt
pushd dependencies
install -d pandoc/${_pandocver}
install -d node
install -d quarto/bin/tools
install -d quarto/share
ln -sfT ${PREFIX}/bin/quarto quarto/bin/quarto
ln -sfT ${PREFIX}/bin/pandoc quarto/bin/tools/pandoc
ln -sfT ${PREFIX}/bin/pandoc pandoc/${_pandocver}/pandoc
ln -sfT ${PREFIX} node/${_nodever}
ln -sfT ${PREFIX}/share/hunspell_dictionaries dictionaries
ln -sfT ${PREFIX}/lib/mathjax mathjax-27
popd

git clone https://github.com/quarto-dev/quarto
ln -sf ${SRC_DIR}/quarto src/gwt/lib
pushd quarto
	rm -rf apps/vscode
	yarn
popd

cmake -S . -B build ${CMAKE_ARGS} \
      -DRSTUDIO_TARGET=Server \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}/lib/rstudio" \
      -DRSTUDIO_USE_SYSTEM_BOOST=yes \
      -DRSTUDIO_USE_SYSTEM_YAML_CPP=yes \
      -DYAML_CPP_INCLUDE_DIR=${PREFIX}/include \
      -DBoost_NO_BOOST_CMAKE=OFF \
      -DBoost_USE_STATIC_LIBS=OFF \
      -DBOOST_ROOT=$PREFIX \
      -DBOOST_INCLUDEDIR=${PREFIX}/include/boost \
      -DBOOST_LIBRARYDIR=${PREFIX}/lib \
      -DQUARTO_ENABLED=TRUE \
      -DRSTUDIO_DISABLE_CRASHPAD=1 \
      -DRSTUDIO_CRASHPAD_ENABLED=FALSE \
      -DRSTUDIO_USE_SYSTEM_SOCI=yes \
      -DSOCI_CORE_LIB=${PREFIX}/lib/libsoci_core.so \
      -DSOCI_POSTGRESQL_LIB=${PREFIX}/lib/libsoci_postgresql.so \
      -DSOCI_SQLITE_LIB=${PREFIX}/lib/libsoci_sqlite3.so

make -j${CPU_COUNT} -C build install

## Put executable symlinks in bin and fixup some resource locations.
ln -sfTr ${PREFIX}/lib/rstudio/resources ${PREFIX}/lib/rstudio/bin/resources
ln -sfTr ${PREFIX}/lib/rstudio/bin/rstudio-server ${PREFIX}/bin/rstudio-server
ln -sfTr ${PREFIX}/lib/rstudio/bin/rserver ${PREFIX}/bin/rserver

## Cleanup
rm -rf ${PREFIX}/opt/rstudio-tools
