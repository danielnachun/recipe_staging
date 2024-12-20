#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

create_java_wrapper() {
    exe_name=$(basename $1)

tee ${PREFIX}/bin/${exe_name//.class/} << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -classpath \${CONDA_PREFIX}/libexec/MCScanX ${exe_name//.class/}
EOF
    chmod +x ${PREFIX}/bin/${exe_name//.class/}
}

export -f create_java_wrapper

add_perl_shebang() {
    exe_name=$(basename $1)

    sed -i '/#!\/usr\/bin\/perl -w/d' ${SRC_DIR}/downstream_analyses/${exe_name}
    sed -i '1i #!/usr/bin/env perl' ${SRC_DIR}/downstream_analyses/${exe_name}
}

export -f add_perl_shebang

make CXX="${CXX} ${CXXFLAGS} ${LDFLAGS}"

mkdir -p ${PREFIX}/bin
install -m 755 MCScanX ${PREFIX}/bin
install -m 755 MCScanX_h ${PREFIX}/bin
install -m 755 duplicate_gene_classifier ${PREFIX}/bin
install -m 755 downstream_analyses/detect_collinear_tandem_arrays ${PREFIX}/bin
install -m 755 downstream_analyses/dissect_multiple_alignment ${PREFIX}/bin

mkdir -p ${PREFIX}/libexec/MCScanX
cp downstream_analyses/*.class ${PREFIX}/libexec/MCScanX
java_exes=(
    bar_plotter
    circle_plotter
    dot_plotter
    dual_synteny_plotter
    family_circle_plotter
    family_tree_plotter
    family_tree_plotter_chr
    family_tree_plotter_show_length
)
find ${PREFIX}/libexec/MCScanX -name *.class | xargs -I % bash -c "create_java_wrapper %"

sed -i '/use Bio::Tools::Run::Alignment::Clustalw;/d' ${SRC_DIR}/downstream_analyses/add_ka_and_ks_to_collinearity.pl
sed -i '/use Bio::Tools::Run::Alignment::Clustalw;/d' ${SRC_DIR}/downstream_analyses/add_kaks_to_synteny.pl
find ${SRC_DIR}/downstream_analyses -name *.pl | xargs -I % bash -c "add_perl_shebang %"
install -m 755 downstream_analyses/*.pl ${PREFIX}/bin
