#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit
LD=$CC

perl Build.PL --extra-compiler-flags="-std=c++14 -Iinclude"
perl ./Build
perl ./Build test
perl ./Build install --installdirs site
