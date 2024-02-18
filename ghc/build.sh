#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export ac_cv_path_CC=${CC}
export ac_cv_path_CXX=${CXX}
export ac_cv_path_RANLIB=${RANLIB}
export ac_cv_path_AR=${AR}
export ac_cv_path_LD=${LD}

pushd binary
	./configure --prefix=${SRC_DIR}/binary \
		--with-gmp-includes=${PREFIX}/include \
		--with-gmp-libraries=${PREFIX}/lib
	make install
	export PATH=${SRC_DIR}/binary/bin:${PATH}
popd

sed -i "s/static_assert/_Static_assert/g" rts/include/Rts.h
if [[ ${target_platform} =~ .*osx.* ]]; then
    sed -i "s/--lflag=-Wl,-no_fixup_chains//g" binary/wrappers/hsc2hs-ghc-9.6.4
    sed -i "s/--lflag=-Wl,-no_fixup_chains//g" binary/bin/hsc2hs-ghc-9.6.4
fi

case ${target_platform} in 
    linux-64)
        build_name="x86_64-unknown-linux"
        host_name=${build_name}
        target_name=${build_name} 
        link_name="x86_64-linux"
        ;;
    linux-arm64)
        build_name="aarch64-unknown-linux" 
        host_name=${build_name}
        target_name=${build_name}
        link_name="aarch64-linux"
        ;;
    linux-ppc64le)
        build_name="powerpc64le-unknown-linux" 
        host_name=${build_name}
        target_name=${build_name}
        link_name="powerpc64le-linux"
        ;;
    osx-64)
        build_name="x86_64-apple-darwin"
        host_name=${build_name}
        target_name=${build_name}
        link_name="x86_64-osx"
        ;;
    osx-arm64)
        build_name="aarch64-apple-darwin"
        host_name=${build_name}
        target_name="aarch64-apple-darwin"
        link_name="aarch64-osx"
        ;;
esac

cabal v2-update
cabal v2-install \
	alex \
	happy \
	--jobs=${CPU_COUNT} \
	--max-backjumps=100000 \
	--install-method=copy \
	--installdir=${SRC_DIR}/binary/bin
./boot.source
./configure \
	--prefix=${PREFIX} \
	--build=${build_name} \
	--host=${host_name} \
	--target=${target_name} \
	--with-intree-gmp
hadrian/build install \
	-j${CPU_COUNT} \
	--prefix=${PREFIX} \
	--flavour=default \
	--docs=none \
	"*.iserv.ghc.link.opts += -optl-Wl,-rpath,${PREFIX}/lib/ghc-${PKG_VERSION}/${link_name}-ghc-${PKG_VERSION}" \
	"*.*.ghc.*.opts += -I${PREFIX}/include"

mkdir -p ${PREFIX}/etc/bash_completion.d
install -m 644 utils/completion/ghc.bash ${PREFIX}/etc/bash_completion.d/ghc
rm ${PREFIX}/lib/ghc-${PKG_VERSION}/lib/package.conf.d/package.cache
rm ${PREFIX}/lib/ghc-${PKG_VERSION}/lib/package.conf.d/package.cache.lock
sed -i "s?${BUILD_PREFIX}/bin/??g" ${PREFIX}/lib/ghc-${PKG_VERSION}/lib/settings
sed -i "s?\"C compiler flags\", \"\"?\"C compiler flags\", \"-I${PREFIX}/include\"?g" ${PREFIX}/lib/ghc-${PKG_VERSION}/lib/settings
sed -i "s?\"C++ compiler flags\", \"\"?\"C++ compiler flags\", \"-I${PREFIX}/include\"?g" ${PREFIX}/lib/ghc-${PKG_VERSION}/lib/settings
sed -i "s?\"C compiler link flags\", \"\"?\"C compiler link flags\", \"-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib\"?g" ${PREFIX}/lib/ghc-${PKG_VERSION}/lib/settings
sed -i "s?\"ld flags\", \"\"?\"ld flags\", \"-L${PREFIX}/lib -rpath,${PREFIX}/lib\"?g" ${PREFIX}/lib/ghc-${PKG_VERSION}/lib/settings
