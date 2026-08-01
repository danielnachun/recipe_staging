#!/bin/bash
export HTSLIB_DIR=$PREFIX
export LD=$CC
perl Build.PL --extra_compiler_flags "-I$PREFIX/include"
perl ./Build CC=${CC}
# Make sure this goes in site
perl ./Build install --installdirs site
