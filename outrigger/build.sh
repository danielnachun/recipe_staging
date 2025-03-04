#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/iteritems/items/g' outrigger/io/gtf.py
$PYTHON setup.py install  --single-version-externally-managed --record=record.txt
