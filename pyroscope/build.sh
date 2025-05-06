#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -modcacherw -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./cmd/pyroscope
go-licenses save ./cmd/pyroscope --save_path=license-files --ignore=github.com/grafana/pyroscope
