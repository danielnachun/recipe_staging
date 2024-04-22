#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
rm -rf polypred_example
rm -rf example_data
rm -rf *.parquet
cp -r "${SRC_DIR}"/* "${PREFIX}/libexec/${PKG_NAME}"

env_script() {
chmod +x ${1}
bin_name=$(basename $1)
tee ${PREFIX}/bin/${bin_name} << EOF
#!/bin/sh
exec python3 ${PREFIX}/libexec/${PKG_NAME}/${bin_name} "\$@"
EOF
}

mkdir -p ${PREFIX}/bin
env_script ${PREFIX}/libexec/${PKG_NAME}/aggregate_finemapper_results.py
env_script ${PREFIX}/libexec/${PKG_NAME}/compute_ldscores.py
env_script ${PREFIX}/libexec/${PKG_NAME}/compute_ldscores_from_ld.py
env_script ${PREFIX}/libexec/${PKG_NAME}/create_finemapper_jobs.py
env_script ${PREFIX}/libexec/${PKG_NAME}/extract_annotations.py
env_script ${PREFIX}/libexec/${PKG_NAME}/extract_snpvar.py
env_script ${PREFIX}/libexec/${PKG_NAME}/finemapper.py
env_script ${PREFIX}/libexec/${PKG_NAME}/ldsc.py
env_script ${PREFIX}/libexec/${PKG_NAME}/munge_polyfun_sumstats.py
env_script ${PREFIX}/libexec/${PKG_NAME}/polyfun.py
env_script ${PREFIX}/libexec/${PKG_NAME}/polyloc.py
env_script ${PREFIX}/libexec/${PKG_NAME}/polypred.py
env_script ${PREFIX}/libexec/${PKG_NAME}/test_polyfun.py
