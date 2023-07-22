#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/-lmupdf-pkcs7 -lmupdf-threads/-lfreetype -lharfbuzz -lz -ljbig2dec -ljpeg -lopenjp2 -lgumbo/' Makefile
make PREFIX=${PREFIX}
install -Dm 755 fbpdf ${PREFIX}/bin/fbpdf-mupdf
install -Dm 755 fbdjvu ${PREFIX}/bin/fbdjvu
install -Dm 644 fbpdf.1 ${PREFIX}/share/man/man1/fbpdf.1
