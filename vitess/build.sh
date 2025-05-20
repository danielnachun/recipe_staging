#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

build_cmd() {
    cmd_name=$1
    echo "Building ${cmd_name}"
    go build -modcacherw -buildmode=pie -trimpath -o=${PREFIX}/bin/${cmd_name} -ldflags="-s -w" ./go/cmd/${cmd_name}
    go-licenses save ./go/cmd/${cmd_name} --save_path=license-files/${cmd_name} --ignore modernc.org/mathutil
}

export -f build_cmd

cmd_names=(
    mysqlctl
    mysqlctld
    vtorc
    vtadmin
    vtctl
    vtctld
    vtctlclient
    vtctldclient
    vtgate
    vttablet
    vtbackup
    vtexplain
)

echo ${cmd_names[@]} | tr ' ' '\n' | xargs -I % bash -c "build_cmd %"
