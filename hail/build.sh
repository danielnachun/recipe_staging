#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd hail
make -C c prebuilt
make python-version-info

export SCALA_VERSION=2.12
./mill hail[].assembly
cp out/hail/${SCALA_VERSION}/assembly.dest/out.jar python/hail/backend/hail-all-spark.jar

mkdir -p build/deploy/src
cp ../README.md build/deploy/

rsync -r \
    --exclude '.eggs/' \
    --exclude '.mypy_cache/' \
    --exclude '.pytest_cache/' \
    --exclude '__pycache__/' \
    --exclude 'benchmark/' \
    --exclude 'docs/' \
    --exclude 'dist/' \
    --exclude 'test/' \
    --exclude '*.log' \
    python/ build/deploy/

cd build/deploy
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
