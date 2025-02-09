# iSSH2

iSSH2 is a bash script for compiling Libssh, Libssh2 and OpenSSL for iOS, macOS, watchOS and tvOS.

- Libssh: [Website](https://www.libssh.org/) | [Documentation](https://api.libssh.org/)
- Libssh2: [Website](http://www.libssh2.org) | [Documentation](http://www.libssh2.org/docs.html) | [Changelog](http://www.libssh2.org/changes.html)
- OpenSSL: [Website](http://www.openssl.org) | [Documentation](http://www.openssl.org/docs/) | [Changelog](http://www.openssl.org/news/)

## Requirements

- Xcode
- Xcode Command Line Tools

#### Optional Requirements

- git (required for automatically detection of latest version of Libssh2/OpenSSL)

## Tested with

- Xcode: 14.2
- iOS SDK: 16.2
- macOS SDK: 13.2

- Libssh: 0.10.4
- Libssh2: 1.10.0
- OpenSSL: 3.0.7

- Architectures: arm64 arm64e x86_64

## How to use

First download and install Cmake [from here](https://cmake.org/download/) and set up
your PATH environment variable to contain /Applications/CMake.app/Contents/bin

1. Download the script
2. Run ./build.sh
3. Done!

You may optionally perform builds directly using iSSH2.sh as below. Note that if you
do this and change the openssl version to 1.x.x or earlier that libssh probably will
not build or work.

If you use the libssh framework you probably will need to add zlib (aka libz) from the
SDK for each platform to each target in your project.

## Script help

```
Usage: iSSH2.sh [options]

This script download and build OpenSSL and Libssh2 libraries.

Options:
  -a, --archs=[ARCHS]       build for [ARCHS] architectures
  -p, --platform=PLATFORM   build for PLATFORM platform
  -v, --min-version=VERS    set platform minimum version to VERS
  -s, --sdk-version=VERS    use SDK version VERS
  -L, --libssh=VERS         download and build Libssh version VERS
  -l, --libssh2=VERS        download and build Libssh2 version VERS
  -o, --openssl=VERS        download and build OpenSSL version VERS
  -x, --xcodeproj=PATH      get info from the project (requires TARGET)
  -t, --target=TARGET       get info from the target (requires XCODEPROJ)
      --build-only-openssl  build OpenSSL and skip Libssh2
      --no-clean            do not clean build folder
      --no-bitcode          don't embed bitcode
  -h, --help                display this help and exit

Valid platforms: iphoneos, iphonesimulator, macosx, appletvos, watchos

Xcodeproj and target or platform and min version must be set.
```

## License

Copyright (c) 2016 Tommaso Madonia. All rights reserved.

```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
