#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

gem install -N -l -V --ignore-dependencies --bindir "${PREFIX}/bin" ${PKG_NAME}-${PKG_VERSION}.gem
gem unpack ${PKG_NAME}-${PKG_VERSION}.gem

tee ${PREFIX}/bin/rufo.cmd << EOF
call %CONDA_PREFIX%\bin\ruby %CONDA_PREFIX%\bin\rufo %*
EOF
