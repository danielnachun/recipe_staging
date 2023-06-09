#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm books/kestrel/axe/x86/examples/popcount/popcount-macho-64.executable

make LISP=${PREFIX}/bin/sbcl ACL2=${SRC_DIR}/saved_acl2 USE_QUICKLISP=0 all basic
make LISP=${PREFIX}/bin/sbcl ACL2_PAR=p ACL2=${SRC_DIR}/saved_acl2p USE_QUICKLISP=0 all basic

mkdir -p ${PREFIX}/libexec/acl2
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc/conda/activate.d/
mkdir -p ${PREFIX}/etc/conda/deactivate.d/

cp -r * ${PREFIX}/libexec/acl2

cat << EOF > ${PREFIX}/etc/conda/activate.d/activate_acl2.sh
#!/bin/sh
export ACL2_SYSTEM_BOOKS="${PREFIX}/libexec/acl2/books"
EOF

cat << EOF > ${PREFIX}/etc/conda/deactivate.d/deactivate_acl2.sh
#!/bin/sh
unset ACL2_SYSTEM_BOOKS
EOF

cat << EOF > ${PREFIX}/bin/acl2
#!/bin/sh
${PREFIX}/bin/sbcl --core "${PREFIX}/libexec/acl2/saved_acl2.core" --userinit /dev/null --eval '(acl2::sbcl-restart)'
EOF

cat << EOF > ${PREFIX}/bin/acl2p
#!/bin/sh
${PREFIX}/bin/sbcl --core "${PREFIX}/libexec/acl2/saved_acl2p.core" --userinit /dev/null --eval '(acl2::sbcl-restart)'
EOF
