#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies ${PKG_NAME}-${PKG_VERSION}.gem
gem unpack ${PKG_NAME}-${PKG_VERSION}.gem
if [[ ${target_platform} =~ .*osx.* ]]; then
    cd ${PREFIX}/share/rubygems/gems/${PKG_NAME}-${PKG_VERSION}/ext
    sed -i "s?\$SDK_INFO\['Path'\]?${CONDA_BUILD_SYSROOT}?" rakefile.rb
    sed -i '/$CFLAGS = "#{$CFLAGS} -mmacosx-version-min=#{$MACOSX_DEPLOYMENT_TARGET}"/d' rakefile.rb
    rake replace_exe
else
    rm -rf ${PREFIX}/share/rubygems/gems/${PKG_NAME}-${PKG_VERSION}/ext
fi
