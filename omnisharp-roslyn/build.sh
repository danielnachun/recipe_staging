#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf global.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"

sed -i "s?<TargetFrameworks>.*</TargetFrameworks>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" \
    src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj
sed -i '/RuntimeFrameworkVersion/d;' src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj
sed -i '/RuntimeIdentifier/d;' src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/libexec/${PKG_NAME}"
dotnet publish --no-self-contained "src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj" \
    -maxcpucount:1 --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}

rm ${PREFIX}/libexec/${PKG_NAME}/OmniSharp
tee ${PREFIX}/bin/OmniSharp << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${DOTNET_ROOT}/dotnet run ${PREFIX}/libexec/${PKG_NAME}/OmniSharp.dll "\$@"
EOF

# Provide additional symlink that is all lowercase on Linux because it is case sensitive
if [[ ${target_platform} =~ .*linux.* ]]; then
    ln -s "${PREFIX}/bin/OmniSharp" "${PREFIX}/bin/omnisharp"
fi
