#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp boot.jar ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/boot << EOF
#!/usr/bin/env bash
declare -a "options=(\$BOOT_JVM_OPTIONS)"
JAVA_HOME=${JAVA_HOME} exec "${JAVA_HOME}/bin/java" "\${options[@]}" -Dboot.app.path="${PREFIX}/bin/boot" -jar "${PREFIX}/libexec/${PKG_NAME}/boot.jar" "\$@"
EOF
