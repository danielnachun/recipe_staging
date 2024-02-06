#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=1
make podman-remote
make podman-remote-darwin-docs
make podman-mac-helper
make install.man install.remote install.completions ETCDIR=${PREFIX}/etc
ln -sf ${PREFIX}/bin/podman ${PREFIX}/bin/podman-remote

#go-licenses save ./cmd/podman --save_path=license-files_podman
go-licenses save ./cmd/podman-mac-helper --save_path=license-files_podman-mac-helper
