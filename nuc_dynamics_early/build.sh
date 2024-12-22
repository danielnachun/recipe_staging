#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's?cdef int s3 = s2/s1?cdef int s3 = int(s2/s1)?' dyn_util.pyx
sed -i 's?(limits\[a,0\]/particle_size)?<int>(limits[a,0]/particle_size)?' dyn_util.pyx
export CFLAGS="${CFLAGS} -I${PREFIX}/lib/python3.12/site-packages/numpy/core/include"
${PREFIX}/bin/python3 setup_cython.py build_ext --build-lib ${PREFIX}/lib/python3.12/site-packages/dyn_util

mkdir -p ${PREFIX}/bin
sed -i '1i #!/usr/bin/env python3' nuc_dynamics.py
install -m 755 nuc_dynamics.py ${PREFIX}/bin/nuc_dynamics
