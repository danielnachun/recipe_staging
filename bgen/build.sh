#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?/usr/include?${PREFIX}/include?g" setup.py
sed -i "s?/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk?${CONDA_BUILD_SYSROOT}?g" setup.py
${PYTHON} -m pip install . -vv
