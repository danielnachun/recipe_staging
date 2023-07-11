#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm global.json
dotnet publish --no-self-contained --output bin -maxcpucount:1 ILSpy.XPlat.slnf --runtime osx-x64
sed -i "s/net6.0/net7.0/" bin/ilspycmd.runtimeconfig.json
sed -i "s/6.0.0/7.0.0/" bin/ilspycmd.runtimeconfig.json
cp -r bin/* ${PREFIX}/libexec/${PKG_NAME}

cat << EOF > ${PREFIX}/bin/ilasm
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/ilasm "\$@"
EOF

cat << EOF > ${PREFIX}/bin/ildasm
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/ildasm "\$@"
EOF

cat << EOF > ${PREFIX}/bin/ilspycmd
#!/bin/sh
DOTNET_ROOT=${DOTNET_ROOT} exec ${PREFIX}/libexec/${PKG_NAME}/ilspycmd "\$@"
EOF
