#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies ${PKG_NAME}-${PKG_VERSION}.gem
gem unpack ${PKG_NAME}-${PKG_VERSION}.gem
if [[ ${target_platform} =~ .*osx.* ]]; then
    cd ${PREFIX}/share/rubygems/gems/${PKG_NAME}-${PKG_VERSION}/ext
    MACOSX_DEPLOYMENT_TARGET=12.0 rake replace_exe
else
    rm -rf ${PREFIX}/share/rubygems/gems/${PKG_NAME}-${PKG_VERSION}/ext
fi
