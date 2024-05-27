#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CABAL_DIR=${SRC_DIR}/.cabal
cabal v2-update
cabal v2-install all \
    --minimize-conflict-set \
    --allow-newer=base,bytestring,text,aeson,hnix,free,algebraic-graphs \
    --extra-lib-dirs=${PREFIX}/lib \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${PREFIX}/bin

echo "package *" >> cabal.project
echo "   ghc-options: -XDuplicateRecordFields" >> cabal.project

mkdir -p ${PREFIX}/share/man/man1
install -m 644 dhall/man/dhall.1 ${PREFIX}/share/man/man1/dhall.1

cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall exe:dhall
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-to-bash exe:dhall-to-bash
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/csv-to-dhall exe:csv-to-dhall
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-to-csv exe:dhall-to-csv
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-docs exe:dhall-docs
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-to-json exe:dhall-to-json
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-to-yaml exe:dhall-to-yaml
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/json-to-dhall exe:json-to-dhall
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-lsp-server exe:dhall-lsp-server
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-to-nix exe:dhall-to-nix
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-to-nixpkgs exe:dhall-to-nixpkgs
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/openapi-to-dhall exe:openapi-to-dhall
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-to-toml exe:dhall-to-toml
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/toml-to-dhall exe:toml-to-dhall
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/dhall-to-yaml-ng exe:dhall-to-yaml-ng
cabal-plan license-report --licensedir=${SRC_DIR}/license-files/yaml-to-dhall exe:yaml-to-dhall
