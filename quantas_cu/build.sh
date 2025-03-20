#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
sed -i "s?/usr/bin/perl -w?${PREFIX}/bin/perl?" scripts/tsu_add_splice_site_usage_CU.pl
sed -i "s?/usr/bin/perl?${PREFIX}/bin/perl?" scripts/*.pl
sed -i "s/tagoverlap.pl/tagoverlap_CU.pl/" scripts/summarise_splice_site_usage_CU.pl
sed -i "s/tag2profile.pl/tag2profile_CU.pl/" scripts/summarise_splice_site_usage_CU.pl
chmod +x scripts/*.pl
cp scripts/*.pl ${PREFIX}/bin
