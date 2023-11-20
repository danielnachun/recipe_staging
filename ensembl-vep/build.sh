#!/usr/bin/env bash

set -o xtrace -o nounset -o errexit

env_script() {
bin_name=$(basename $1)
dir_name=$(dirname $1)
full_path=$1

tee ${PREFIX}/bin/${bin_name} << EOF
#!/bin/sh

PERL5LIB="\${PERL5LIB}:${dir_name}" PATH=${PREFIX}/bin:\${PATH} exec ${full_path} "\$@"
EOF
chmod 0755 ${PREFIX}/bin/${bin_name}
}

export -f env_script

export C_INCLUDE_PATH=$PREFIX/include
target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
# Strip .X subversion from vep package version to get plugins version
version=${PKG_VERSION%%.*}
mkdir -p $target
mkdir -p $PREFIX/bin


# Use insecure CURL
sed -i.bak 's/curl -s --location/curl -k -s --location/' INSTALL.pl
# Use vep_convert_cache.pl from vep_install.pl
sed -i.bak 's@/convert_cache.pl@/vep_convert_cache@' INSTALL.pl
# Find plugins in install directory
sed -i.bak "s@'dir_plugins=s,'@'dir_plugins=s' => (\$RealBin || []),@" vep
# Change location where INSTALL.pl looks for the zlib headers
sed -i -e "s@/usr/include/zlib.h@${PREFIX}/include@" INSTALL.pl

# Copy executables & modules
cp convert_cache.pl $target/vep_convert_cache
cp INSTALL.pl $target/vep_install
cp filter_vep $target/filter_vep
cp vep $target/vep
cp haplo $target/haplo
cp variant_recoder $target/variant_recoder
cp -r modules $target/modules

chmod 0755 $target/
env_script $target/vep_convert_cache
env_script $target/vep_install
env_script $target/filter_vep
env_script $target/vep
env_script $target/haplo
env_script $target/variant_recoder

pushd $target
    # Use external Bio::DB::HTS::Faidx instead of compiling interally
    # Compile in VEP causes issues linking to /lib64 outside of rpath
    vep_install -a a --NO_HTSLIB --NO_TEST --NO_BIOPERL --NO_UPDATE
    # Remove test data
    rm -rf t/
popd

# Install plugins
mv VEP_plugins/*.pm ${target}
mv VEP_plugins/config ${target}

# Install loftee
sed -i "s?'/vep/loftee'?${target}?" loftee/LoF.pm
mv loftee/*.pl ${target}
mv loftee/*.pm ${target}
mv loftee/maxEntScan ${target}
mv loftee/splice_data ${target}
