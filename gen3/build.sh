#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/entry_points().get("gen3.plugins", \[\])/entry_points(group = "gen3.plugins")/' gen3/cli/pfb.py
sed -i 's/entry_points().get("gen3.plugins", \[\])/entry_points(group = "gen3.plugins")/' gen3/cli/users.py

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
