#!/usr/bin/env bash

install -Dd "${PREFIX}/opt/polyfun"
cp -r "${SRC_DIR}"/* "${PREFIX}/opt/polyfun"

install -Dd "${PREFIX}/bin"
ln -sf "${PREFIX}/opt/polyfun/munge_polyfun_sumstats.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/opt/polyfun/polyfun.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/opt/polyfun/polyloc.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/opt/polyfun/extract_snpvar.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/opt/polyfun/finemapper.py" "${PREFIX}/bin"
ln -sf "${PREFIX}/opt/polyfun/test_polyfun.py" "${PREFIX}/bin"
