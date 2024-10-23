#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

install_script() {
    script_name=$1
    chmod +x ${PREFIX}/libexec/${PKG_NAME}/${script_name}.py
    sed -i '1i #!/usr/bin/env python3' ${PREFIX}/libexec/${PKG_NAME}/${script_name}.py

tee ${PREFIX}/bin/${script_name} << EOF
    #!/usr/bin/env bash

    exec \${CONDA_PREFIX}/libexec/${PKG_NAME}/${script_name}.py "\$@"
EOF
}

export -f install_script

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp ${SRC_DIR}/bin/*.py ${PREFIX}/libexec/${PKG_NAME}

script_names=(
    recommend
)

echo ${script_names[@]} | tr ' ' '\n' | xargs -I % bash -c 'install_script %'
