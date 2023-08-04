#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export COURSIER_CACHE=${SRC_DIR}/.coursier

mkdir -p .ivy2
mkdir -p .sbt
mkdir -p .coursier
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Build with support for the latest minor version of all recent major versions of Scala
sbt -sbt-dir $SRC_DIR/.sbt -ivy $SRC_DIR/.ivy2 quick-publish-local
# Copy jar files from snapshot to libexec
cp -r $SRC_DIR/.ivy2/local/org.scalameta/**/**/jars/*.jar ${PREFIX}/libexec/${PKG_NAME}
# Copy dependencies from Coursier cache to libexec
sbt -sbt-dir $SRC_DIR/.sbt -ivy $SRC_DIR/.ivy2 compile 'show metals/dependencyClasspath' 2>/dev/null | \
    grep Attributed | sed 's/^[^\*]\+\* Attributed(\([^)]\+\).*/\1/g' | \
    grep .jar | \
    xargs --replace=% cp -r % ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/metals << EOF
#!/bin/sh
JAVA_HOME=${PREFIX}/lib/jvm exec \${JAVA_HOME}/bin/java -cp "${PREFIX}/libexec/${PKG_NAME}/*" scala.meta.metals.Main "\$@"
EOF
