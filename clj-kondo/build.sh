#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

lein uberjar

native-image \
    --native-compiler-options="-L${PREFIX}/lib" \
    -J-Xmx3G \
    -jar target/clj-kondo-${PKG_VERSION}-standalone.jar \
    -H:+ReportExceptionStackTraces \
    --no-fallback \
    --verbose

mkdir -p ${PREFIX}/bin
install -m 755 clj-kondo ${PREFIX}/bin

lein pom
mvn license:download-licenses -Dgoal=download-licenses
