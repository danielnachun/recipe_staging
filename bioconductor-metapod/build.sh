#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
PKG_CPPFLAGS=-DHAVE_WORKING_LOG1P
CXX14=$CXX" > ~/.R/Makevars
R CMD INSTALL --build .
