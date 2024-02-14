#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export LDFLAGS="-s -w"
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="${LDFLAGS}" ./cmd/${PKG_NAME}
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/qemu-wrapper -ldflags="${LDFLAGS}" ./cmd/qemu-wrapper
go-licenses save ./cmd/${PKG_NAME} --save_path=license-files_${PKG_NAME}
go-licenses save ./cmd/qemu-wrapper --save_path=license-files_qemu-wrapper

if [[ ${target_platform} =~ .*linux.* ]]; then
    go build -buildmode=pie -trimpath -o=${PREFIX}/bin/vm -ldflags="${LDFLAGS}" ./cmd/vm
    go-licenses save ./cmd/vm --save_path=license-files_vm
fi
