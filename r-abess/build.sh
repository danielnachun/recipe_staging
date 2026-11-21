#!/bin/bash
export DISABLE_AUTOBREW=1
sed -i "s?-lomp?${LDFLAGS} -lomp?" configure
sed -i "s?-Xclang -fopenmp?${CXXFLAGS} -Xclang -fopenmp?" configure
sed -i 's/conftest\.c/conftest.${ac_ext}/' configure
R CMD INSTALL --build . ${R_ARGS}
