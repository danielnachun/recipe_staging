#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export GOPATH=${BUILD_PREFIX}
export GO111MODULE=auto

build_dir=${BUILD_PREFIX}/src/github.com/laurent22/massren
mkdir -p ${build_dir}
cp -r * ${build_dir}
cd ${build_dir}
go build -o ${PREFIX}/bin/massren
