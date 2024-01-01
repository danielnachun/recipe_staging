#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"

sed -i "s?<TargetFrameworks>.*</TargetFrameworks>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" \
    src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj
sed -i '/RuntimeFrameworkVersion/d;' src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj
sed -i '/RuntimeIdentifier/d;' src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj

# On Linux, make sure the linker uses conda prefix and sysroot for libraries instead of host
# Also needed for proper ICU detection
# This variable is ignored on macOS.
export LD_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/libexec/${PKG_NAME}"
dotnet publish --no-self-contained "src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj" \
    -maxcpucount:1 --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

tee ${PREFIX}/bin/OmniSharp << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/OmniSharp "\$@"
EOF

# Provide additional symlink that is all lowercase on Linux because it is case sensitive
if [[ ${target_platform} =~ .*linux.* ]]; then
    ln -s "${PREFIX}/bin/OmniSharp" "${PREFIX}/bin/omnisharp"
fi
