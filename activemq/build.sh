#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

rm -rf bin/linux-*
rm -rf bin/macosx

if [[ $target_platform =~ .*osx.* ]]; then
    osdir="macosx"
    libext="jnilib"
fi
if [[ $target_platform =~ .*linux.* ]]; then
    osdir="linux-x86-64"
    libext="so"
fi

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/activemq/bin/${osdir}
cp -r * ${PREFIX}/libexec/activemq

ln -sf ${PREFIX}/libexec/activemq/bin/activemq ${PREFIX}/bin
ln -sf ${PREFIX}/bin/wrapper ${PREFIX}/libexec/activemq/bin/${osdir}/wrapper
ln -sf ${PREFIX}/lib/libwrapper.jar ${PREFIX}/libexec/activemq/bin/${osdir}/libwrapper.jar
ln -sf ${PREFIX}/lib/libwrapper.${libext} ${PREFIX}/libexec/activemq/bin/${osdir}/libwrapper.${libext}
