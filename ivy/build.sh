#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

ant jar
cp build/artifact/jars/ivy.jar ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/ivy << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec ${JAVA_HOME}/bin/java -jar "${PREFIX}/libexec/${PKG_NAME}/ivy.jar" "\$@"
EOF

chmod +x ${PREFIX}/bin/ivy
${PREFIX}/bin/ivy -makepom ${SRC_DIR}/pom.xml -properties ${SRC_DIR}/version.properties
sed -i 's?<artifactId>jsch.agentproxy</artifactId>?<artifactId>jsch.agentproxy</artifactId><type>pom</type>?' pom.xml
mvn license:download-licenses -Dgoal=download-licenses
