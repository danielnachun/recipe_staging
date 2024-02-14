#!/bin/sh

if [[ $(uname) == "Darwin" ]]; then
    arch=$(uname -m | sed -e s/arm64/aarch64/)
    codesign --sign - --entitlements ${PREFIX}/share/${PKG_NAME}/entitlements.xml --force ${PREFIX}/bin/qemu-system-${arch}
fi
