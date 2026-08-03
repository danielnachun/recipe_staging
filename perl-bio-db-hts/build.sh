#!/bin/bash
export HTSLIB_DIR=$PREFIX
export CC=${BUILD_PREFIX}/bin/${CC}
export LD=$CC
perl Build.PL --extra_compiler_flags "-I$PREFIX/include"
perl ./Build
# Make sure this goes in site
perl ./Build install --installdirs site
