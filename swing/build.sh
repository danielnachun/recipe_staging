#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s/\['Swing'\]/['Swing', 'Swing.util']/g" setup.py
${PYTHON} -m pip install . -vvv
