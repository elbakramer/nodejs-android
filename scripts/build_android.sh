#!/bin/bash

# Based on guidelines and hints in the following pages:
# - https://developer.android.com/ndk/guides/other_build_systems
# - https://github.com/nodejs/node/blob/main/android_configure.py
# - https://github.com/nodejs-mobile/nodejs-mobile/blob/mobile-master/android-configure
# - https://github.com/nodejs-mobile/nodejs-mobile/blob/mobile-master/tools/android_build.sh

set -e

INSTALL_DIR="$PWD/installs/node"

NODE_VERSION="${NODE_VERSION:-18.12.1}"
NODE_SRC_PATH="${NODE_SRC_PATH:-$PWD/srcs/node-v$NODE_VERSION-patched}"

ANDROID_NDK_VERSION="${ANDROID_NDK_VERSION:-25}"

BOOST_VERSION="${BOOST_VERSION:-1.80.0}"
BOOST_ROOT="${BOOST_ROOT:-$PWD/srcs/boost_${BOOST_VERSION//./_}}"

HOST_OS="linux"
HOST_ARCH="x86_64"

TARGET_OS="android"

ANDROID_NDK_PATH="$PWD/tools/android-ndk-r${ANDROID_NDK_VERSION}b"
TOOLCHAIN="$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/$HOST_OS-$HOST_ARCH"

TARGET_AARCH64="aarch64-linux-android"
TARGET_ARMV7A="armv7a-linux-androideabi"
TARGET_I686="i686-linux-android"
TARGET_X86_64="x86_64-linux-android"

TARGET_ARCH_AARCH64="arm64"
TARGET_ARCH_ARMV7A="arm"
TARGET_ARCH_I686="ia32"
TARGET_ARCH_X86_64="x64"

MIN_SDK_VERSION="28"

export ANDROID_NDK_PATH
export TOOLCHAIN

export BOOST_ROOT

TARGETS="$TARGET_AARCH64 $TARGET_ARMV7A $TARGET_I686 $TARGET_X86_64"
TARGETS="$TARGET_ARMV7A $TARGET_I686 $TARGET_X86_64"

pushd "$NODE_SRC_PATH"

for TARGET in $TARGETS
do

  case $TARGET in
    "$TARGET_AARCH64")
      TARGET_ARCH="$TARGET_ARCH_AARCH64"
      ;;
    "$TARGET_ARMV7A")
      TARGET_ARCH="$TARGET_ARCH_ARMV7A"
      ;;
    "$TARGET_I686")
      TARGET_ARCH="$TARGET_ARCH_I686"
      ;;
    "$TARGET_X86_64")
      TARGET_ARCH="$TARGET_ARCH_X86_64"
      ;;
  esac

  export CCACHE="$(which ccache)"

  export API="$MIN_SDK_VERSION"

  export AR="$TOOLCHAIN/bin/llvm-ar"
  export CC="$CCACHE $TOOLCHAIN/bin/$TARGET$API-clang"
  export AS="$CC"
  export CXX="$CCACHE $TOOLCHAIN/bin/$TARGET$API-clang++"
  export LD="$TOOLCHAIN/bin/ld"
  export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
  export STRIP="$TOOLCHAIN/bin/llvm-strip"

  export CC_host="$CCACHE $(which gcc)"
  export AR_host="$(which ar)"
  export CXX_host="$CCACHE $(which g++)"
  export LINK_host="$CXX_host"

  export CC_target="$CC"
  export AR_target="$AR"
  export CXX_target="$CXX"
  export LINK_target="$CXX_target"

  GYP_DEFINES=""
  GYP_DEFINES+=" target_arch=$TARGET_ARCH"
  GYP_DEFINES+=" v8_target_arch=$TARGET_ARCH"
  GYP_DEFINES+=" android_target_arch=$TARGET_ARCH"
  GYP_DEFINES+=" host_os=$HOST_OS"
  GYP_DEFINES+=" target_os=$TARGET_OS"

  export GYP_DEFINES

  rm -rf ./out/

  PREFIX="$INSTALL_DIR/$TARGET"

  # options are basically from: https://github.com/nodejs/node/blob/main/android_configure.py
  # --openssl-no-asm due to: https://github.com/nodejs/node/blob/main/BUILDING.md#openssl-asm-support
  # --without-intl due to cross compilation issue like: i386:x86-64 architecture of input file '...' is incompatible with i386 output
  #   - might have to change $NODE/tools/icu/icu-generic.gyp
  #   - might have to look into workaround here: https://github.com/termux/termux-packages/blob/84a049d1c09f783960e9ad802d38e9e11f795cfc/packages/nodejs/build.sh#L26-L47
  ./configure \
    --prefix="$PREFIX" \
    --dest-cpu="$TARGET_ARCH" \
    --dest-os="$TARGET_OS" \
    --openssl-no-asm \
    --without-intl \
    --cross-compiling \
    --shared

  # make clean build just in case
  make clean
  make -j $(getconf _NPROCESSORS_ONLN)

  # cannot execute with the just built node in host
  # since it's built for android
  SYSTEM_NODE="$(which node)"
  if [ ! -z "$SYSTEM_NODE" ]
  then
    NODE="$SYSTEM_NODE" make doc-only
  fi

  # install to prefix location
  mkdir -p "$PREFIX"
  make install

done

popd

