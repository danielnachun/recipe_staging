#!/bin/bash

gem install -N -l -V --norc --ignore-dependencies ${PKG_NAME}-${PKG_VERSION}.gem --install-dir=${PREFIX}/share/rubygems
gem unpack ${PKG_NAME}-${PKG_VERSION}.gem

sed -i "s?exec \"\$bindir\/ruby\"?GEM_HOME=\"${PREFIX}/share/rubygems\" exec \"ruby\"?g" ${PREFIX}/share/rubygems/bin/ascli
sed -i "s?exec \"\$bindir\/ruby\"?GEM_HOME=\"${PREFIX}/share/rubygems\" exec \"ruby\"?g" ${PREFIX}/share/rubygems/bin/asession
