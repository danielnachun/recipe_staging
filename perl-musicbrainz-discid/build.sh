#!/usr/bin/env bash

set -o errexit -o pipefail -o xtrace

perl Makefile.PL INSTALLDIRS=site
make CCFLAGS="${CFLAGS}" OTHERLDFLAGS="${LDFLAGS} -ldiscid -L${CONDA_BUILD_SYSROOT}/usr/lib"
make test
make install
