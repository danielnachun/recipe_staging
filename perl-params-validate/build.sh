#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit
LD=${CC}

perl Build.PL
perl ./Build
perl ./Build test
perl ./Build install --installdirs site
