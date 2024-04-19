#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
rm -rf polypred_example
rm -rf example_data
rm -rf *.parquet
cp -r "${SRC_DIR}"/* "${PREFIX}/libexec/${PKG_NAME}"

env_script() {
bin_name=$(basename $1)
tee ${PREFIX}/bin/${bin_name} << EOF
#!/bin/sh
exec ${PREFIX}/libexec/${PKG_NAME}/${bin_name} "\$@"
EOF
}

mkdir -p ${PREFIX}/bin
env_script munge_polyfun_sumstats.py
env_script polyfun.py
env_script polyloc.py
env_script extract_snpvar.py
env_script finemapper.py
env_script test_polyfun.py
