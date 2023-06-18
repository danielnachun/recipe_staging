#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's?#!/usr/bin/perl?#!/usr/bin/env perl?' abcde-musicbrainz-tool
make install prefix=${PREFIX} sysconfdir=${PREFIX}/etc
