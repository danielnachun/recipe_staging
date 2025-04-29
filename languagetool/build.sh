#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Install JAR files
mkdir -p ${PREFIX}/libexec/languagetool
mkdir -p ${PREFIX}/bin

# Build with maven
./build-zip.sh

mv languagetool-standalone/target/LanguageTool-${PKG_VERSION}.zip ${SRC_DIR}
unzip LanguageTool-${PKG_VERSION}.zip
cp -r LanguageTool-${PKG_VERSION}/* ${PREFIX}/libexec/languagetool

# Create bash and batch wrappers
tee ${PREFIX}/bin/languagetool << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/languagetool/languagetool-commandline.jar "\$@"
EOF
chmod +x ${PREFIX}/bin/languagetool

tee ${PREFIX}/bin/languagetool.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\languagetool\languagetool-commandline.jar %*
EOF
