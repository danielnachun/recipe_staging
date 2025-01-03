#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}

rm -rf scripts/synphoni
rm -rf scripts/step1_make_dists.py
rm -rf scripts/step2_filter_pairs.py
rm -rf scripts/step3_find_og_commus.py
rm -rf scripts/step4_OG_communities_to_blocks_graph_check.py

install_perl_script() {
    script_name=$(basename $1)
    # Set shebang to use /usr/bin/env perl
    sed -i 's?#!/usr/bin/perl -w?#!/usr/bin/env perl?' ${SRC_DIR}/scripts/${script_name}
    sed -i 's?#!/usr/bin/perl?#!/usr/bin/env perl?' ${SRC_DIR}/scripts/${script_name}
    sed -i 's/\r$//' ${SRC_DIR}/scripts/${script_name}
    sed -i 's/^ #/#/' ${SRC_DIR}/scripts/${script_name}

    install -m 755 ${SRC_DIR}/scripts/${script_name} ${PREFIX}/bin/${script_name//.pl/}
}

export -f install_perl_script

install_r_script() {
    script_name=$(basename $1)
    sed -i '1i #!/usr/bin/env Rscript' ${SRC_DIR}/scripts/${script_name}
    install -m 755 ${SRC_DIR}/scripts/${script_name} ${PREFIX}/bin/${script_name//.R/}
}

export -f install_r_script

install_python_script() {
    script_name=$(basename $1)
    install -m 755 ${SRC_DIR}/scripts/${script_name} ${PREFIX}/bin/${script_name//.py/}
}

export -f install_python_script

perl_script_names=$(find ${SRC_DIR}/scripts -name "*.pl")
python_script_names=$(find ${SRC_DIR}/scripts -name "*.py")
r_script_names=$(find ${SRC_DIR}/scripts -name "*.R")

echo ${perl_script_names[@]} | tr ' ' '\n' | xargs -I % bash -c 'install_perl_script %'
echo ${python_script_names[@]} | tr ' ' '\n' | xargs -I % bash -c 'install_python_script %'
echo ${r_script_names[@]} | tr ' ' '\n' | xargs -I % bash -c 'install_r_script %'
