#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd hail
make -C c prebuilt

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

tee python/hailtop/version.py << EOF
__pip_version__ = "0.0"
__revision__ = "0.0"
__version__ = "${PKG_VERSION}"
EOF

tee python/hail/version.py << EOF
__pip_version__ = "0.0"
__revision__ = "0.0"
__version__ = "${PKG_VERSION}"
EOF

tee python/hail/docs/_static/hail_version.js << EOF
hail_pip_version = "0.0";
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
