#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}/bin

sed -i "s?\${HOMEBREW_RUBY_PATH}?${BUILD_PREFIX}/bin/ruby?g" install.sh
sed -i "s?libexec?libexec/${PKG_NAME}?g" install.sh
sed -i "s?libexec?libexec/${PKG_NAME}?g" clojure
./install.sh ${PREFIX}
mv ${PREFIX}/bin/clj ${PREFIX}/libexec/${PKG_NAME}/bin/clj
mv ${PREFIX}/bin/clojure ${PREFIX}/libexec/${PKG_NAME}/bin/clojure

tee ${PREFIX}/bin/clj << EOF
#/bin/sh
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/clj "\$@"
EOF

tee ${PREFIX}/bin/clojure << EOF
#/bin/sh
JAVA_HOME=${PREFIX}/lib/jvm exec ${PREFIX}/libexec/${PKG_NAME}/bin/clojure "\$@"
EOF
