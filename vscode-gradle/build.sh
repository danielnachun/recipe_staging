#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./gradlew build

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin
cp -r extension/lib/* ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/gradle-language-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/gradle-language-server/gradle-server "\$@"
EOF

tee ${PREFIX}/bin/gradle-language-server.bat << EOF
call %CONDA_PREFIX%\libexec\gradle-language-server\gradle-server.bat %*
EOF
