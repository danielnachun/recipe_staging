#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies ${PKG_NAME}-${PKG_VERSION}.gem
gem unpack ${PKG_NAME}-${PKG_VERSION}.gem
if [[ ${target_platform} =~ .*osx.* ]]; then
    cd ${PREFIX}/share/rubygems/gems/${PKG_NAME}-${PKG_VERSION}/ext
    unset MACOSX_DEPLOYMENT_TARGET
    if [[ ${target_platform} == "osx-arm64" ]]; then
        export SDKROOT=/Applications/Xcode_15.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    fi
    rake replace_exe
else
    rm -rf ${PREFIX}/share/rubygems/gems/${PKG_NAME}-${PKG_VERSION}/ext
fi
