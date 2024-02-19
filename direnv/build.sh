#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=1
make install PREFIX=${PREFIX}
go-licenses save . --save_path=license-files
