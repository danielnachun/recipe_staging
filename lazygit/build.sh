#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# go one level up
cd "$SRC_DIR"
cd ..

# create the gopath directory structure
export GOPATH=$PWD/gopath
mkdir -p "$GOPATH/src/github.com/jesseduffield"
ln -s "$SRC_DIR" "$GOPATH/src/github.com/jesseduffield/lazygit"
cd "$GOPATH/src/github.com/jesseduffield/lazygit"

# build the project
export CGO_ENABLED=0  # disable CGO, as there are no C libs to load
LDFLAGS="-s -w"       # omit the symbol table / debug information and
                      # DWARF symbol table.
go build  -ldflags "${LDFLAGS}"

# install the binary
mkdir -p "$PREFIX/bin"
mv "$GOPATH/../work/lazygit" "$PREFIX/bin"
