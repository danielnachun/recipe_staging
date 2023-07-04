#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# normally the build sets the version from git, we don't have a git repo so
# just override it manually
sed -i "s/0.0.1-local/${PKG_VERSION}/" scripts/common.cake
sed -i "s/0.0.1.0/${PKG_VERSION%.*}.0.0/" scripts/common.cake

# only built STDIO because Http driver doesn't support OpenSSL 3.0 yet
sed -i 's/"OmniSharp.Stdio.Driver",/"OmniSharp.Stdio.Driver"/;/OmniSharp.Http.Driver/d' build.json

case $target_platform in
    osx-64 )
        sed -i '/osx-arm64/d' build.cake ;;
    osx-arm64 )
        sed -i '/osx-x64/d' build.cake ;;
    linux-64 )
        sed -i '/linux-arm64/d;/linux-musl/d' build.cake ;;
    linux-arm64 )
        sed -i '/linux-x64/d;/linux-musl/d/d;' build.cake ;;
esac

# don't set RuntimeFrameworkVersion, just build against the version we are using
# this is needed since otherwise we will use a crossgen compiler version built
# against an older .NET 6 that does not have OpenSSL 3 support
sed -i '/RuntimeFrameworkVersion/d;' build.cake
sed -i '/RuntimeFrameworkVersion/d;' src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj

# use arch-packaged .NET version rather than forcing this version
rm global.json

# use absolute path to global dotnet exe
sed -i "s|? \"dotnet\"|? \"$(command -v dotnet)\"|" scripts/common.cake

export DOTNET_NOLOGO=1
# On Linux, make sure the linker uses conda prefix and sysroot for libraries instead of host
# Also needed for proper ICU detection
if [[ ${target_platform} =~ .*linux.* ]]; then
    export LD_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"
fi

dotnet tool restore
dotnet cake --target PublishNet6Builds --configuration Release --exclusive --use-global-dotnet-sdk

mkdir -p "${PREFIX}/libexec"
case $target_platform in
    osx-64 )
        cp -a "artifacts/publish/OmniSharp.Stdio.Driver/osx-x64/net6.0" "${PREFIX}/libexec/${PKG_NAME}" ;;
    osx-arm64 )
        cp -a "artifacts/publish/OmniSharp.Stdio.Driver/osx-arm64/net6.0" "${PREFIX}/libexec/${PKG_NAME}" ;;
    linux-64 )
        cp -a "artifacts/publish/OmniSharp.Stdio.Driver/linux-x64/net6.0" "${PREFIX}/libexec/${PKG_NAME}" ;;
    linux-arm64 )
        cp -a "artifacts/publish/OmniSharp.Stdio.Driver/linux-arm64/net6.0" "${PREFIX}/libexec/${PKG_NAME}" ;;
esac

mkdir -p "${PREFIX}/usr/bin"
ln -s "${PREFIX}/libexec/${PKG_NAME}/OmniSharp" "${PREFIX}/bin/OmniSharp"
# Provide additional symlink that is all lowercase on Linux because it is case sensitive
if [[ ${target_platform} =~ .*linux.* ]]; then
    ln -s "${PREFIX}/libexec/${PKG_NAME}/OmniSharp" "${PREFIX}/bin/omnisharp"
fi
