#!/bin/bash

set -o errexit -o pipefail
LD=$CC

perl Build.PL
perl ./Build
perl ./Build test
perl ./Build install --installdirs site
