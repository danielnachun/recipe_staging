#!/usr/bin/env bash

set -o xtrace -o nounset -o errexit

export C_INCLUDE_PATH=$PREFIX/include
perl_lib=${PREFIX}/lib/perl5/site_perl
mkdir -p ${perl_lib}
mkdir -p ${PREFIX}/bin

# Use insecure CURL
sed -i.bak 's/curl -s --location/curl -k -s --location/' INSTALL.pl
# Use vep_convert_cache.pl from vep_install.pl
sed -i.bak 's@/convert_cache.pl@/vep_convert_cache@' INSTALL.pl
# Find plugins in install directory
sed -i.bak "s@'dir_plugins=s,'@'dir_plugins=s' => (\$RealBin || []),@" vep
# Change location where INSTALL.pl looks for the zlib headers
sed -i -e "s@/usr/include/zlib.h@${PREFIX}/include@" INSTALL.pl

# Copy executables & modules
install -m 755 convert_cache.pl ${PREFIX}/bin/vep_convert_cache
install -m 755 INSTALL.pl ${PREFIX}/bin/vep_install
install -m 755 filter_vep ${PREFIX}/bin/filter_vep
install -m 755 vep ${PREFIX}/bin/vep
install -m 755 haplo ${PREFIX}/bin/haplo
install -m 755 variant_recoder ${PREFIX}/bin/variant_recoder
cp -r modules/* ${perl_lib}

echo "A" | ${PREFIX}/bin/vep_install -a a --NO_HTSLIB --NO_TEST --NO_BIOPERL --NO_UPDATE --DESTDIR ${perl_lib}
cp -r modules/* ${perl_lib}

# Install plugins
mv VEP_plugins/*.pm ${perl_lib}
mv VEP_plugins/config ${perl_lib}

# Install loftee
sed -i "s?'/vep/loftee'?${perl_lib}?" loftee/LoF.pm
mv loftee/*.pl ${perl_lib}
mv loftee/*.pm ${perl_lib}
mv loftee/maxEntScan ${perl_lib}
mv loftee/splice_data ${perl_lib}
