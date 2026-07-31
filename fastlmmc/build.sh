#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# -dead_strip_dylibs would drop the BLAS/LAPACK dylib because FastLmmC resolves
# its symbols lazily; keep it linked.
export LDFLAGS=$(echo ${LDFLAGS} | sed 's/-Wl,-dead_strip_dylibs//g')

# Pick the math-library backend per architecture.  Intel MKL is only available
# (and only makes sense) on x86_64; everywhere else -- AArch64 Linux and Apple
# Silicon -- we use OpenBLAS via the portable USE_OPENBLAS code path.
case "${target_platform}" in
    linux-64)
        export BLAS_DEFINE="-DUSE_MKL"
        export BLAS_LDFLAGS="-lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5"
        export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/intel64/lp64"
        ;;
    *)
        export BLAS_DEFINE="-DUSE_OPENBLAS"
        export BLAS_LDFLAGS="-lopenblas"
        ;;
esac

# The link step wraps the math libraries in a GNU-ld --start-group and adds
# -lrt (clock_gettime on old glibc); both are Linux-only.
if [[ "${target_platform}" == linux-* ]]; then
    export LINUX=1
fi

cd Cpp
sh DoMkl_linux.sh
mkdir -p ${PREFIX}/bin
install -m 755 fastlmmc_mkl ${PREFIX}/bin/fastlmmc
ln -sf ${PREFIX}/bin/fastlmmc ${PREFIX}/bin/fastlmm
