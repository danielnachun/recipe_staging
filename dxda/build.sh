#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -o=${PREFIX}/bin/dx-download-agent -ldflags="-s -w" ./cmd/dx-download-agent
go-licenses save ./cmd/dx-download-agent --save_path=license-files
