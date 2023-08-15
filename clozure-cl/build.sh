#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*osx.* ]]; then
    ./dx86cl64 -n -l lib/x8664env.lisp \
        -e "(ccl:xload-level-0)" \
        -e "(ccl:compile-ccl)" \
        -e "(quit)"
tee image << EOF
(ccl:save-application "dx86cl64.image")
(quit)
EOF
    cat image | ./dx86cl64 -n --image-name x86-boot64.image
    rm -rf dx86cl64
    rm -rf dx86cl64.image
else
    ./lx86cl64 -n -l lib/x8664env.lisp \
        -e "(ccl:rebuild-ccl :full t)" \
        -e "(quit)"
tee image << EOF
(ccl:save-application "lx86cl64.image")
(quit)
EOF
    cat image | ./lx86cl64 -n --image-name x86-boot64
    rm -rf lx86cl64
    rm -rf lx86cl64.image
fi

rm -rf x86-headers64
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/share/doc/${PKG_NAME}
mkdir -p ${PREFIX}/bin

cp -r * ${PREFIX}/libexec/${PKG_NAME}
cp -r doc/* ${PREFIX}/share/doc/${PKG_NAME}

tee ${PREFIX}/bin/ccl64 << EOF
#!/bin/sh
CCL_DEFAULT_DIRECTORY=${PREFIX}/libexec/${PKG_NAME} exec ${PREFIX}/libexec/${PKG_NAME}/scripts/ccl64 "\$@"
EOF
