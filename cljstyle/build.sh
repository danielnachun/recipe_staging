#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

lein uberjar

native-image \
    -jar target/uberjar/cljstyle.jar \
    --native-image-info \
    --native-compiler-options="-L${PREFIX}/lib" \
    --initialize-at-build-time \
    --report-unsupported-elements-at-runtime \
    --no-fallback \
    --no-server \
    -H:Name=cljstyle \
    -H:Log=registerResource: \
    -H:+ReportExceptionStackTraces \
    -J-Dclojure.spec.skip-macros=true \
    -J-Dclojure.compiler.direct-linking=true \
    -J-Xmx4500m \
    --verbose

mkdir -p ${PREFIX}/bin
install -m 755 cljstyle ${PREFIX}/bin
