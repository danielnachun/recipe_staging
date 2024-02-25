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
sed -i 's/unary_function/__unary_function/' src/imslib/src/ims/utils/compose_f_gx_t.h
sed -i 's/binary_function/__binary_function/' src/imslib/src/ims/utils/compose_f_gx_hy_t.h
$R CMD INSTALL --build .
