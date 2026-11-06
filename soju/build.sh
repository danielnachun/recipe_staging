#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -modcacherw -buildmode=pie -trimpath -o=${PREFIX}/bin/soju -ldflags="-s -w" ./cmd/soju
go build -modcacherw -buildmode=pie -trimpath -o=${PREFIX}/bin/sojuctl -ldflags="-s -w" ./cmd/sojuctl
go build -modcacherw -buildmode=pie -trimpath -o=${PREFIX}/bin/sojudb -ldflags="-s -w" ./cmd/sojudb
go-licenses save ./cmd/soju --save_path=license-files_soju --ignore=codeberg.org/emersion/soju
go-licenses save ./cmd/sojuctl --save_path=license-files_sojuct --ignore=codeberg.org/emersion/soju
go-licenses save ./cmd/sojudb --save_path=license-files_sojudb --ignore=codeberg.org/emersion/soju
