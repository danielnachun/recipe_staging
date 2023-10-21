#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd src
sed -i 's?#!/usr/bin/perl?#!/usr/bin/env perl?' MakeDefaults.pl
sed -i 's?#!/usr/bin/perl?#!/usr/bin/env perl?' roc_area.pl
sed -i 's?#!/usr/bin/perl?#!/usr/bin/env perl?' score_directory.pl
mkdir -p ${PREFIX}/bin

make CXX=${CXX} MODEL_TYPE="-DRNA=1"
install -m 755 contralign ${PREFIX}/bin/contralign-rna
rm -rf contralign

make CXX=${CXX} MODEL_TYPE="-DRNA=0"
install -m 755 contralign ${PREFIX}/bin/contralign-protein

install -m 755 MakeDefaults.pl ${PREFIX}/bin
install -m 755 roc_area.pl ${PREFIX}/bin
install -m 755 score_directory.pl ${PREFIX}/bin
