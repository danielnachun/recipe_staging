#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    cyclonedx-${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/cdxgen << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@cyclonedx/cdxgen/bin/cdxgen.js "\$@"
EOF
chmod +x ${PREFIX}/bin/cdxgen

tee ${PREFIX}/bin/cdxgen.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@cyclonedx\cdxgen\bin\cdxgen.js %*
EOF

tee ${PREFIX}/bin/cdx-verify << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@cyclonedx/cdxgen/bin/verify.js "\$@"
EOF
chmod +x ${PREFIX}/bin/cdx-verify

tee ${PREFIX}/bin/cdx-verify.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@cyclonedx\cdxgen\bin\verify.js %*
EOF

tee ${PREFIX}/bin/cdxgen-secure << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@cyclonedx/cdxgen/bin/cdxgen.js "\$@"
EOF
chmod +x ${PREFIX}/bin/cdxgen-secure

tee ${PREFIX}/bin/cdxgen-secure.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@cyclonedx\cdxgen\bin\cdxgen.js %*
EOF

tee ${PREFIX}/bin/cdxi << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@cyclonedx/repl/bin/repl.js "\$@"
EOF
chmod +x ${PREFIX}/bin/cdxi

tee ${PREFIX}/bin/cdxi.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@cyclonedx\repl\bin\repl.js %*
EOF

tee ${PREFIX}/bin/evinse << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@cyclonedx/cdxgen/bin/evinse.js "\$@"
EOF
chmod +x ${PREFIX}/bin/evinse

tee ${PREFIX}/bin/evinse.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@cyclonedx\cdxgen\bin\evinse.js %*
EOF

tee ${PREFIX}/bin/cbom << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@cyclonedx/cdxgen/bin/cdxgen.js "\$@"
EOF
chmod +x ${PREFIX}/bin/cbom

tee ${PREFIX}/bin/cbom.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@cyclonedx\cdxgen\bin\cdxgen.js %*
EOF

tee ${PREFIX}/bin/obom << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@cyclonedx/cdxgen/bin/cdxgen.js "\$@"
EOF
chmod +x ${PREFIX}/bin/obom

tee ${PREFIX}/bin/obom.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@cyclonedx\cdxgen\bin\cdxgen.js %*
EOF

tee ${PREFIX}/bin/saasbom << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@cyclonedx/cdxgen/bin/cdxgen.js "\$@"
EOF
chmod +x ${PREFIX}/bin/saasbom

tee ${PREFIX}/bin/saasbom.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@cyclonedx\cdxgen\bin\cdxgen.js %*
EOF
