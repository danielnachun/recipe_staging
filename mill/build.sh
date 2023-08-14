#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

./mill -i show dev.assembly
install -m 644 out/dev/assembly.dest/out-tmp.jar ${PREFIX}/libexec/${PKG_NAME}/mill.jar
install -m 755 out/dev/assembly.dest/mill ${PREFIX}/libexec/${PKG_NAME}/mill

tee ${PREFIX}/bin/mill << EOF
#!/bin/sh
JAVA_HOME=${JAVA_HOME} exec ${PREFIX}/libexec/${PKG_NAME}/mill "\$@"
EOF
