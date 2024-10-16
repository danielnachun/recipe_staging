#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mv impute5.zip_ impute5.zip
# Use echo because unzip does not return 0 despite a successful extraction
echo $(unzip impute5.zip)
unzip impute5_v${PKG_VERSION}.zip

mkdir -p ${PREFIX}/bin
install -m 755 impute5_v${PKG_VERSION}/impute5_v${PKG_VERSION}_static ${PREFIX}/bin/impute5
install -m 755 impute5_v${PKG_VERSION}/imp5Chunker_v${PKG_VERSION}_static ${PREFIX}/bin/imp5Chunker
install -m 755 impute5_v${PKG_VERSION}/xcftools_static ${PREFIX}/bin/xcftools
