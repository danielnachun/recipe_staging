#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export LINKFLAGS="${LDFLAGS}"
export SBCL_MACOSX_VERSION_MIN=10.9
./make.sh --prefix=${PREFIX} \
    --xc-host="ecl --norc" \
    --with-sb-core-compression \
    --with-sb-ldb \
    --with-sb-thread
export INSTALL_ROOT=${PREFIX}
sh install.sh

mkdir -p ${PREFIX}/etc/conda/activate.d/
mkdir -p ${PREFIX}/etc/conda/deactivate.d/

cat << EOF > ${PREFIX}/etc/conda/activate.d/activate_sbcl.sh
#!/bin/sh
export SBCL_HOME=\$CONDA_PREFIX/lib/sbcl
export SBCL_SOURCE_ROOT=\$CONDA_PREFIX/share/sbcl/src
EOF

cat << EOF > ${PREFIX}/etc/conda/deactivate.d/deactivate_sbcl.sh 
#!/bin/sh
unset SBCL_HOME
unset SBCL_SOURCE_ROOT
EOF

mkdir -p ${PREFIX}/share/sbcl
cp -r contrib ${PREFIX}/share/sbcl
cp -r src ${PREFIX}/share/sbcl

cat << EOF > ${PREFIX}/lib/sbcl/sbclrc
    (setf (logical-pathname-translations "SYS")
        '(("SYS:SRC;**;*.*.*" #p"${PREFIX}/share/sbcl/src/**/*.*")
            ("SYS:CONTRIB;**;*.*.*" #p"${PREFIX}/share/sbcl/contrib/**/*.*")))
EOF
