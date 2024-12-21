#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
install -m 755 GenomeSyn-${PKG_VERSION}/bin/GenomeSyn ${PREFIX}/bin
install -m 755 GenomeSyn-${PKG_VERSION}/bin/Transform ${PREFIX}/bin
install -m 755 GenomeSyn-${PKG_VERSION}/bin/do_mummer.sh ${PREFIX}/bin
install -m 755 GenomeSyn-${PKG_VERSION}/bin/svg_pdf.py ${PREFIX}/bin
