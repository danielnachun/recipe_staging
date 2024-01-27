#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

script/version
script/build
script/install ${PREFIX}

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/fish/vendor_completions.d
install -m 644 contrib/completion/mas-completion.bash ${PREFIX}/etc/bash_completion.d/mas
install -m 644 contrib/completion/mas.fish ${PREFIX}/fish/vendor_completions.d
