#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd hail
make -C c prebuilt

tee python/hailtop/version.py << EOF
__pip_version__ = "placeholder"
__revision__ = "placeholder"
__version__ = "${PKG_VERSION}"
EOF

tee python/hail/docs/_static/hail_version.js << EOF
hail_pip_version = "placeholder";
hail_version = "${PKG_VERSION}";
EOF

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
