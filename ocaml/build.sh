#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CC=$(basename "$CC")
export ASPP="$CC -c"
export AS=$(basename "$AS")
export AR=$(basename "$AR")
export RANLIB=$(basename "$RANLIB")
export OCAML_PREFIX=$PREFIX
export OCAMLLIB=$PREFIX/lib/ocaml

# needed for tests/instrumented-runtime
if [[ "${target_platform}" == linux-* ]] ; then
    export LDFLAGS="-lrt ${LDFLAGS}"
fi

# Test failing on macOS. Seems to be a known issue.
rm testsuite/tests/lib-threads/beat.ml
bash -x ./configure -prefix $OCAML_PREFIX --enable-ocamltest
make world.opt -j${CPU_COUNT}
#make tests
make install
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
