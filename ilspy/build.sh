#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm global.json
case ${target_platform} in 
    osx-64 )
        dotnet publish --no-self-contained ILSpy.XPlat.slnf -maxcpucount:1 --output bin --runtime osx-x64
        rm -rf bin/InstrumentationEngine/ubuntu ;;
    osx-arm64 )
        dotnet publish --no-self-contained ILSpy.XPlat.slnf -maxcpucount:1 --output bin --runtime osx-arm64
        rm -rf bin/InstrumentationEngine/ubuntu ;;
    linux-64 )
        dotnet publish --no-self-contained ILSpy.XPlat.slnf -maxcpucount:1 --output bin --runtime linux-x64
        rm -rf bin/InstrumentationEngine/macos ;;
    linux-arm64 )
        dotnet publish --no-self-contained ILSpy.XPlat.slnf -maxcpucount:1 --output bin --runtime linux-arm64
        rm -rf bin/InstrumentationEngine/macos ;;
esac

rm -rf bin/InstrumentationEngine/alpine
sed -i "s/net6.0/net7.0/" bin/ilspycmd.runtimeconfig.json
sed -i "s/6.0.0/7.0.0/" bin/ilspycmd.runtimeconfig.json
cp -r bin/* ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/ilasm << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/ilasm "\$@"
EOF

tee ${PREFIX}/bin/ildasm << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/ildasm "\$@"
EOF

tee ${PREFIX}/bin/ilspycmd << EOF
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/ilspycmd "\$@"
EOF
