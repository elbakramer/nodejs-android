#!/bin/bash

ROOT_INSTALLED_DIR="$1"

if [ -z "$ROOT_INSTALLED_DIR" ]
then
  exit
fi

DIST="./dists/nodejs-android/"
DIST_VERSION="0.1.0"

rm -rf "$DIST"
mkdir -p "$DIST"

TARGET_AARCH64="aarch64-linux-android"
TARGET_ARMV7A="armv7a-linux-androideabi"
TARGET_I686="i686-linux-android"
TARGET_X86_64="x86_64-linux-android"

TARGETS="$TARGET_AARCH64 $TARGET_ARMV7A $TARGET_I686 $TARGET_X86_64"

# copy shared libs
for TARGET in $TARGETS
do
  PREFIX="$ROOT_INSTALLED_DIR/$TARGET"
  SHARED_LIB="$PREFIX/lib/libnode.so"

  DIST_TARGET_LIB_DIR="$DIST/bin/$TARGET/"
  mkdir -p "$DIST_TARGET_LIB_DIR"
  cp "$SHARED_LIB" "$DIST_TARGET_LIB_DIR"
done

# copy header files
cp -r "$ROOT_INSTALLED_DIR/$TARGET_AARCH64/include" "$DIST"

# make archive from dist folder
tar -cvzf "nodejs-android-v$DIST_VERSION.tar.gz" "$DIST" --transform "s/$(basename "$DIST")/nodejs-android-v$DIST_VERSION/"

