#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export XML_CATALOG_FILES="${PREFIX}/etc/xml/catalog"

create_catalog() {
    catalog_version=$1
    catalog_path="${PREFIX}/share/docbook/xml/${catalog_version}/catalog.xml"

    xmlcatalog --nooout --del file://${catalog_path} ${XML_CATALOG_FILES}
    xmlcatalog --nooout --add nextCatalog file://${catalog_path} ${XML_CATALOG_FILES}
}

if [ ! -d ${PREFIX}/etc/xml/catalog ]; then
    xmlcatalog --noout --create ${PREFIX}/etc/xml/catalog
fi

xml_versions=(42 412 43 44 45 50 51)
echo ${xml_versions[@]} | tr ' ' '\n' | xargs -I % create_catalog %
