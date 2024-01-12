#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

meson setup output/release \
    --sysconfdir=${PREFIX}/etc \
    -Dmad=disabled \
    -Dmpcdec=disabled \
    -Dsoundcloud=disabled \
    -Dao=enabled \
    -Dbzip2=enabled \
    -Dexpat=enabled \
    -Dffmpeg=enabled \
    -Dfluidsynth=enabled \
    -Dnfs=enabled \
    -Dshout=enabled \
    -Dupnp=pupnp \
    -Dvorbisenc=enabled \
    -Dwavpack=enabled \
    -Dsystemd_system_unit_dir=${PREFIX}/lib/systemd/system \
    -Dsystemd_user_unit_dir=${PREFIX}/systemd/user \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --buildtype=release \
    --wrap-mode=nofallback
meson compile -C output/release --verbose
meson install -C output/release
