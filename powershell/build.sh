#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export NUGET_PACKAGES="$PWD/nuget"
export LD_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"

rm global.json
dotnet restore src/powershell-unix
dotnet restore src/ResGen
dotnet restore src/TypeCatalogGen
dotnet restore src/Modules

cp "${RECIPE_DIR}/Microsoft.PowerShell.SDK.csproj.TypeCatalog.targets" "src/Microsoft.PowerShell.SDK/obj/Microsoft.PowerShell.SDK.csproj.TypeCatalog.targets"
dotnet msbuild src/Microsoft.PowerShell.SDK/Microsoft.PowerShell.SDK.csproj /t:_GetDependencies "/property:DesignTimeBuild=true;_DependencyFile=${SRC_DIR}/src/TypeCatalogGen/powershell.inc" /nologo

pushd src/ResGen
    dotnet run
popd

pushd src/TypeCatalogGen
    dotnet run ../System.Management.Automation/CoreCLR/CorePsTypeCatalog.cs powershell.inc
popd

ln -sf ${PREFIX}/lib/libpsl-native${SHLIB_EXT} src/powershell-unix/libpsl-native${SHLIB_EXT}

mkdir -p ${PREFIX}/libexec/powershell/7

dotnet publish --no-self-contained src/powershell-unix --output ${PREFIX}/libexec/powershell/7

mkdir -p ${PREFIX}/libexec/powershell/7/Modules/PSReadLine
mkdir -p ${PREFIX}/libexec/powershell/7/Modules/PackageManagement
mkdir -p ${PREFIX}/libexec/powershell/7/Modules/PowerShellGet
mkdir -p ${PREFIX}/libexec/powershell/7/Modules/ThreadJob

cp -r nuget/psreadline/**/* ${PREFIX}/libexec/powershell/7/Modules/PSReadLine
cp -r nuget/packagemanagement/**/* ${PREFIX}/libexec/powershell/7/Modules/PackageManagement
cp -r nuget/powershellget/**/* ${PREFIX}/libexec/powershell/7/Modules/PowerShellGet
cp -r nuget/threadjob/**/* ${PREFIX}/libexec/powershell/7/Modules/ThreadJob

rm -rf ${PREFIX}/libexec/powershell/7/libmi${SHLIB_EXT}
ln -sf ${PREFIX}/lib/libmi${SHLIB_EXT} ${PREFIX}/libexec/powershell/7

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/pwsh << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/powershell/7/pwsh "\$@"
EOF
