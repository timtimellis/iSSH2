#!/bin/bash
                                   #########
#################################### iSSH2 #####################################
#                                  #########                                   #
# Copyright (c) 2013 Tommaso Madonia. All rights reserved.                     #
#                                                                              #
# Permission is hereby granted, free of charge, to any person obtaining a copy #
# of this software and associated documentation files (the "Software"), to deal#
# in the Software without restriction, including without limitation the rights #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    #
# copies of the Software, and to permit persons to whom the Software is        #
# furnished to do so, subject to the following conditions:                     #
#                                                                              #
# The above copyright notice and this permission notice shall be included in   #
# all copies or substantial portions of the Software.                          #
#                                                                              #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,#
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN    #
# THE SOFTWARE.                                                                #
################################################################################

source "$BASEPATH/iSSH2-commons"

set -e

mkdir -p "$LIBSSH1DIR"

LIBSSH1_TAR="libssh-$LIBSSH1_VERSION.tar.xz"

LIBSSH1_MAJOR_VERSION=`echo $LIBSSH1_VERSION | egrep -E -o "\d+\.\d+"`

downloadFile "https://www.libssh.org/files/$LIBSSH1_MAJOR_VERSION/libssh-$LIBSSH1_VERSION.tar.xz" "$LIBSSH1DIR/$LIBSSH1_TAR"

LIBSSH1SRC="$LIBSSH1DIR/src/"
mkdir -p "$LIBSSH1SRC"

set +e
echo "Extracting $LIBSSH1_TAR"
tar -Jxkf "$LIBSSH1DIR/$LIBSSH1_TAR" -C "$LIBSSH1DIR/src" --strip-components 1 2>&-
set -e

echo "Building Libssh $LIBSSH1_VERSION:"

for ARCH in $ARCHS
do
  PLATFORM="$(platformName "$SDK_PLATFORM" "$ARCH")"
  OPENSSLDIR="$BASEPATH/openssl_$SDK_PLATFORM/"
  PLATFORM_SRC="$LIBSSH1DIR/${PLATFORM}_$SDK_VERSION-$ARCH/src"
  PLATFORM_OUT="$LIBSSH1DIR/${PLATFORM}_$SDK_VERSION-$ARCH/install"
  LIPO_SSH="$LIPO_SSH $PLATFORM_OUT/lib/libssh.a"

  HEADER_INSTALL_PATH="$PLATFORM_OUT/include/libssh/"
  #HEADER_INSTALL_PATH="$PLATFORM_SRC/include/libssh/"

  if [[ -f "$PLATFORM_OUT/lib/libssh.a" ]]; then
    echo "libssh.a for $ARCH already exists."
  else
    rm -rf "$PLATFORM_SRC"
    rm -rf "$PLATFORM_OUT"
    mkdir -p "$PLATFORM_OUT"
    cp -R "$LIBSSH1SRC" "$PLATFORM_SRC"
    cd "$PLATFORM_OUT/../"

    LOG="$PLATFORM_OUT/build-libssh.log"
    touch $LOG

    if [[ "$ARCH" == arm64* ]]; then
      HOST="aarch64-apple-darwin"
    else
      HOST="$ARCH-apple-darwin"
    fi

    export DEVROOT="$DEVELOPER/Platforms/$PLATFORM.platform/Developer"
    export SDKROOT="$DEVROOT/SDKs/$PLATFORM$SDK_VERSION.sdk"
    export CC="$CLANG"
    export CPP="$CLANG++"
    export CFLAGS="-arch $ARCH -pipe -no-cpp-precomp -isysroot $SDKROOT -m$SDK_PLATFORM-version-min=$MIN_VERSION $EMBED_BITCODE"
    export CPPFLAGS="-arch $ARCH -pipe -no-cpp-precomp -isysroot $SDKROOT -m$SDK_PLATFORM-version-min=$MIN_VERSION"

    echo $CLANG

    export OPENSSL_ROOT_DIR=$OPENSSLDIR

    cmake $PLATFORM_SRC -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER_WORKS=1 -DCMAKE_CXX_COMPILER="$CPP" -DWITH_GSSAPI=OFF -DWITH_ZLIB=OFF -DWITH_SERVER=OFF -DWITH_SFTP=ON -DWITH_PCAP=ON -DWITH_GEX=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="$CPPFLAGS" -DCMAKE_C_FLAGS="$CFLAGS" -DCMAKE_INSTALL_PREFIX="$PLATFORM_OUT" >> "$LOG" 2>&1

    make -j "$BUILD_THREADS" install >> "$LOG" 2>&1

    echo "- $PLATFORM $ARCH done!"
  fi
done

lipoFatLibrary "$LIPO_SSH" "$BASEPATH/libssh_$SDK_PLATFORM/lib/libssh.a"

importHeaders "$PLATFORM_SRC/include/libssh/" "$BASEPATH/libssh_$SDK_PLATFORM/include"
importHeaders2 "$HEADER_INSTALL_PATH" "$BASEPATH/libssh_$SDK_PLATFORM/include"

echo "Building done."

