#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}

install_script() {
    script_name=$1
    cp ${SRC_DIR}/RetroNet/pipeline/${script_name}.py ${PREFIX}/libexec/${PKG_NAME}
    chmod +x ${PREFIX}/libexec/${PKG_NAME}/${script_name}.py
    sed -i '1i #!/usr/bin/env python3' ${PREFIX}/libexec/${PKG_NAME}/${script_name}.py

tee ${PREFIX}/bin/${script_name} << EOF
    #!/usr/bin/env bash

    exec ${PREFIX}/libexec/${PKG_NAME}/${script_name}.py "\$@"
EOF
}

export -f install_script

python_scripts=(
    RetroNet
    generate_bed
)

echo ${python_scripts[@]} | tr ' ' '\n' | xargs -I % bash -c 'install_script %'

support_scripts=(
    ALU_Inpection.py
    LINE_Inpection.py
    SVA_Inpection.py
)

echo ${support_scripts[@]} | tr ' ' '\n' | xargs -I % bash -c "install -m 644 ${SRC_DIR}/RetroNet/pipeline/% ${PREFIX}/libexec/${PKG_NAME}/%"
