#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build archive with jar and other files
./script/bootstrap

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r bin ${PREFIX}/libexec/${PKG_NAME}
cp -r lib ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/cljsc << EOF
CLOJURESCRIPT_HOME=\${CONDA_PREFIX}/libexec/clojurescript \${CONDA_PREFIX}/libexec/clojurescript/bin/cljsc
EOF

tee ${PREFIX}/bin/cljsc.cmd << EOF
CLOJURESCRIPT_HOME=%CONDA_PREFIX%\libexec\clojurescript %CONDA_PREFIX%\libexec\clojurescript\bin\cljsc.bat
EOF

# Download licenses for dependencies
mvn license:download-licenses -Dgoal=download-licenses
