#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
sed -ie 's/PKG_CPPFLAGS=/PKG_CPPFLAGS=-DHAVE_WORKING_LOG1P /' src/Makevars
$R CMD INSTALL --build .
