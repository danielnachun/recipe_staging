#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build package with dotnet publish
rm -rf global.json
rm -rf NuGet.Config

# Replace hardcoded .NET version
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
sed -i "s?<TargetFrameworks>.*</TargetFrameworks>?<TargetFrameworks>net${framework_version}</TargetFrameworks>?" \
    src/SonarScanner.MSBuild/SonarScanner.MSBuild.csproj
dotnet publish --no-self-contained src/SonarScanner.MSBuild/SonarScanner.MSBuild.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework "net${framework_version}"
rm ${PREFIX}/libexec/${PKG_NAME}/SonarScanner.MSBuild

# Create bash and batch wrappers
tee ${PREFIX}/bin/sonar-scanner-msbuild << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/sonar-scanner-msbuild/SonarScanner.MSBuild.dll "\$@"
EOF

tee ${PREFIX}/bin/sonar-scanner-msbuild.cmd << EOF
exec %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\sonar-scanner-msbuild\SonarScanner.MSBuild.dll %*
EOF

# Download dependency licenses wtih dotnet-project-licenses
dotnet-project-licenses --input src/SonarScanner.MSBuild/SonarScanner.MSBuild.csproj -t -d license-files
