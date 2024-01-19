#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

install_catalog() {
    catalog_version=$1
    mkdir -p ${PREFIX}/share/docbook/xml/${catalog_version}
    pushd "xml${catalog_version}"
        if [[ $1 == "412" ]]; then
            cp ${PREFIX}/share/docbook/xml/4.2/catalog.xml .
            sed -i 's/V4.2 ../V4.1.2' catalog.xml
            sed -i 's/4.2/V4.1.2' catalog.xml
        fi
        rm -rf docs
        cp -R ./* ${PREFIX}/share/docbook/xml/${catalog_version}
    popd
}

export -f install_catalog

xml_versions=(4.2 4.1.2 4.3 4.4 4.5 5.0 5.1)
echo ${xml_versions[@]} | tr ' ' '\n' | xargs -I % bash -c "install_catalog %"
