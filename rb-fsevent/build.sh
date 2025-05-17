#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export ARCHFLAGS="-arch x86_64"
if [[ ${target_platform} == "osx-arm64" ]]; then
    export ARCHFLAGS="-arch arm64"
fi

gem install -N -l -V --ignore-dependencies rb-fsevent-${PKG_VERSION}.gem
gem unpack rb-fsevent-${PKG_VERSION}.gem
if [[ ${target_platform} =~ .*osx.* ]]; then
    cd ${PREFIX}/share/rubygems/gems/rb-fsevent-${PKG_VERSION}/ext
    sed -i "s?\$SDK_INFO\['Path'\]?\"${CONDA_BUILD_SYSROOT}\"?" rakefile.rb
    sed -i '/$CFLAGS = "#{$CFLAGS} -mmacosx-version-min=#{$MACOSX_DEPLOYMENT_TARGET}"/d' rakefile.rb
    rake replace_exe
    rm -rf ${PREFIX}/share/rubygems/gems/rb-fsevent-${PKG_VERSION}/ext/build
else
    rm -rf ${PREFIX}/share/rubygems/gems/rb-fsevent-${PKG_VERSION}/ext
fi
