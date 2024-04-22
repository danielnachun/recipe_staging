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
exec python3 ${PREFIX}/libexec/${PKG_NAME}/${bin_name} "\$@"
EOF
}

mkdir -p ${PREFIX}/bin
env_script aggregate_finemapper_results.py
env_script compute_ldscores.py
env_script compute_ldscores_ld.py
env_script create_finemapper_jobs.py
env_script extract_annotations.py
env_script extract_snpvar.py
env_script finemapper.py
env_script ldsc.py
env_script munge_polyfun_sumstats.py
env_script polyfun.py
env_script polyloc.py
env_script polypred.py
env_script test_polyfun.py
