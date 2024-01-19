#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export OPAMROOT=${SRC_DIR}/opamroot
export OPAMYES=1
export SETUPTOOLS_USE_DISTUTILS=stdlib

opam init --no-setup --disable-sandboxing
opam update -y
opam install -vvv -j ${CPU_COUNT} -y --deps-only --no-depexts ./libs/ocaml-tree-sitter-core
opam install -vvv -j ${CPU_COUNT} -y --deps-only --no-depexts ./

pushd ./libs/ocaml-tree-sitter-core
	./configure --prefix ${PREFIX}
popd

opam install -vvv -j ${CPU_COUNT} --deps-only --no-depexts -y .
opam exec -- make core
opam exec -- make copy-core-for-cli

mkdir -p ${PREFIX}/bin
install -m 755 _build/install/default/bin/semgrep-core ${PREFIX}/bin/semgrep-core

export SEMGREP_SKIP_BIN=1
cd cli
${PYTHON} -m pip install . -vv
