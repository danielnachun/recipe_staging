#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

xcodebuild -arch x86_64 \
    -project "Terminal Notifier.xcodeproj" \
    -target terminal-notifier \
    SYMROOT=build \
    -verbose \
    MACOSX_DEPLOYMENT_TARGET= 12.0 \
    CODE_SIGN_IDENTITY=
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r build/Release/terminal-notifier.app ${PREFIX}/libexec/${PKG_NAME}

tee ${PREFIX}/bin/terminal-notifier << EOF
#!/bin/sh
exec ${PREFIX}/libexec/terminal-notifier/terminal-notifier.app/Contents/MacOS/terminal-notifier "\$@"
EOF
