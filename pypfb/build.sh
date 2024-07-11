#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/entry_points().get("pfb.plugins", \[\])/entry_points(group = "pfb.plugins")/' src/pfb/cli.py
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
