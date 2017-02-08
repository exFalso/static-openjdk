#!/bin/bash

set -euo pipefail

# clone jdk
hg clone http://hg.openjdk.java.net/jdk9/jdk9
cd jdk9
bash ./get_source.sh

# apply patches
hg import ../enable-static-linux.patch
(
    cd hotspot
    hg import ../../hostpot-fix-minmax.patch
)

# configure, switch off some warnings
WNO='-Wno-deprecated-declarations -Wno-maybe-uninitialized'
bash ./configure --enable-static-build=yes --enable-ccache=yes --with-extra-cflags=$WNO --with-extra-cxxflags=$WNO

# build, this will fail
make || true

if [ ! -f ./build/linux-x86_64-normal-server-release/jdk/lib/server/libjvm.a ]
   echo Can\'t find ./build/linux-x86_64-normal-server-release/jdk/lib/server/libjvm.a
   exit 1
fi
