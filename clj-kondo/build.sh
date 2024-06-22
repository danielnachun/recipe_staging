#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

lein with-profiles +clojure-1.10.2 "do" clean, uberjar

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
