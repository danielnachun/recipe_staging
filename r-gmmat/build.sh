#!/bin/bash

export DISABLE_AUTOBREW=1
sed -i 's?-Izstd/lib/common?-Izstd/lib/common -DHAVE_WORKING_LOG1P?' configure

# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}
