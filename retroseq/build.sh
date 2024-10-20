#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/lib/perl5/vendor_perl

install -m 644 ${SRC_DIR}/RetroSeq/Utilities.pm ${PREFIX}/lib/perl5/vendor_perl/RetroSeq/Utilities.pm
install -m 644 ${SRC_DIR}/RetroSeq/Vcf.pm ${PREFIX}/lib/perl5/vendor_perl/RetroSeq/Vcf.pm

install -m 755 ${SRC_DIR}/RetroSeq/retroseq.prun.pl ${PREFIX}/bin/retroseq
