#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

lein uberjar

native-image \
    --no-server \
    --native-compiler-options="-L${PREFIX}/lib" \
    -J-Xmx7G \
    -J-Xms4G \
    -jar target/zprint-filter-${PKG_VERSION} \
    -H:Name=zprintl \
    -H:EnableURLProtocols=https,http \
    -H:+ReportExceptionStackTraces \
    --report-unsupported-elements-at-runtime \
    --initialize-at-build-time \
    --no-fallback \
    --verbose

mkdir -p ${PREFIX}/bin
install -m 755 zprintl ${PREFIX}/bin
