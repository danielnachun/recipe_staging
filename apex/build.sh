#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/Eigen::all/Eigen::placeholders::all/' src/fitModels.hpp
sed -i -E 's/Spectra::SymEigsSolver< double, Spectra::LARGEST_ALGE, (Spectra::DenseSymMatProd<double>) >([^(]*)\(&op,/Spectra::SymEigsSolver< \1 >\2(op,/' src/fitModels.cpp
sed -i 's/eigs\.compute();/eigs.compute(Spectra::SortRule::LargestAlge);/' src/fitModels.cpp

# Symlink args.hxx from taywee-args into source tree
mkdir "${SRC_DIR}/src/args"
ln -sf "${PREFIX}/include/args.hxx" "${SRC_DIR}/src/args"

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/eigen3" 
make CXX="${CXX}"

mkdir -p ${PREFIX}/bin
install -m 755 bin/apex ${PREFIX}/bin/apex
