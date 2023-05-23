#!/bin/bash

sed -i 's/import rfunc/from tensorqtl import rfunc/g' tensorqtl/post.py
sed -i 's/from collections/from collections.abc/g' tensorqtl/rfunc.py

$PYTHON -m pip install . -vv
