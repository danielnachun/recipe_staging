#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

ant abcl.properties.autoconfigure.openjdk.8
ant

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/abcl
mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d
install -m 644 dist/abcl.jar ${PREFIX}/libexec/abcl
install -m 644 dist/abcl-contrib.jar ${PREFIX}/libexec/abcl

cat << EOF > ${PREFIX}/bin/abcl
#!/bin/sh
exec rlwrap java -cp ${PREFIX}/libexec/abcl/abcl.jar:"\$CLASSPATH" org.armedbear.lisp.Main "\$@"
EOF

cat << EOF > ${PREFIX}/etc/conda/activate.d/activate_abcl.sh
#!/bin/sh
export JAVA_HOME=${PREFIX}
EOF

cat << EOF > ${PREFIX}/etc/conda/deactivate.d/deactivate_abcl.sh
#!/bin/sh
unset JAVA_HOME
EOF
