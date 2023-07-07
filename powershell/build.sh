#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export NUGET_PACKAGES=${SRC_DIR}/nuget
export POWERSHELL_GIT_DESCRIBE_OUTPUT="v${PKG_VERSION}-0-gxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export LD_LIBRARY_PATH="${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib"

sed -i "s/<Exec Command='git describe --abbrev=60 --long'/<Exec Command='echo \$POWERSHELL_GIT_DESCRIBE_OUTPUT'/" PowerShell.Common.props

rm global.json
dotnet restore src/powershell-unix
dotnet restore src/ResGen
dotnet restore src/TypeCatalogGen
dotnet restore src/Modules

cp "${RECIPE_DIR}/Microsoft.PowerShell.SDK.csproj.TypeCatalog.targets" "src/Microsoft.PowerShell.SDK/obj/Microsoft.PowerShell.SDK.csproj.TypeCatalog.targets"
dotnet msbuild src/Microsoft.PowerShell.SDK/Microsoft.PowerShell.SDK.csproj /t:_GetDependencies "/property:DesignTimeBuild=true;_DependencyFile=${SRC_DIR}/src/TypeCatalogGen/powershell.inc" /nologo

touch DELETE_ME_TO_DISABLE_CONSOLEHOST_TELEMETRY

pushd src/ResGen
    dotnet run
popd

pushd src/TypeCatalogGen
    dotnet run ../System.Management.Automation/CoreCLR/CorePsTypeCatalog.cs powershell.inc
popd

ln -sf ${PREFIX}/lib/libpsl-native${SHLIB_EXT} src/powershell-unix/libpsl-native${SHLIB_EXT}

mkdir -p ${PREFIX}/libexec/powershell/7
case ${target_platform} in 
    osx-64 )
        dotnet publish --no-self-contained --configuration Darwin src/powershell-unix --output bin --runtime osx-x64
        cp -r src/powershell-unix/bin/Darwin/net7.0/osx-x64/* ${PREFIX}/libexec/powershell/7 ;;
    osx-arm64 )
        dotnet publish --no-self-contained --configuration Darwin src/powershell-unix --output bin --runtime osx-arm64
        cp -r src/powershell-unix/bin/Darwin/net7.0/osx-arm64/* ${PREFIX}/libexec/powershell/7 ;;
    linux-64 )
        dotnet publish --no-self-contained --configuration Linux src/powershell-unix --output bin --runtime linux-x64
        cp -r src/powershell-unix/bin/Linux/net7.0/linux-x64/* ${PREFIX}/libexec/powershell/7 ;;
    linux-arm64 )
        dotnet publish --no-self-contained --configuration Linux src/powershell-unix --output bin --runtime linux-arm64
        cp -r src/powershell-unix/bin/Linux/net7.0/linux-arm64/* ${PREFIX}/libexec/powershell/7 ;;
esac

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
ln -sf ${PREFIX}/libexec/powershell/7/pwsh ${PREFIX}/bin
