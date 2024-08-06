#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
dotnet publish --no-self-contained src/nbgv/nbgv.csproj --output ${PREFIX}/libexec/${PKG_NAME}
rm ${PREFIX}/libexec/${PKG_NAME}/nbgv

# Create bash and batch wrappers
tee ${PREFIX}/bin/nbgv << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/nerdbank.gitversioning/nbgv.dll "\$@"
EOF

tee ${PREFIX}/bin/nbgv.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\nerdbank.gitversioning\nbgv.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
tee ignored_packages.json << EOF
["Microsoft.DotNet.PlatformAbstractions", "LibGit2Sharp*"]
EOF
dotnet-project-licenses --input src/nbgv/nbgv.csproj -t -d license-files -ignore ignored_packages.json
