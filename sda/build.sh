#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mv sda.zip_ sda.zip
# Use echo because unzip does not return 0 despite a successful extraction
echo $(unzip sda.zip)

mkdir -p ${PREFIX}/bin
if [[ ${target_platform} =~ .*osx.* ]]; then
	install -m 755 sda_static_osx ${PREFIX}/bin/sda
else
	install -m 755 sda_static_linux ${PREFIX}/bin/sda
fi
