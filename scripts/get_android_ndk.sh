#!/bin/bash

DOWNLOADS="./downloads/"
TOOLS="./tools/"

mkdir -p "$DOWNLOADS"
mkdir -p "$TOOLS"

ANDROID_NDK_VERSION="${ANDROID_NDK_VERSION:-25}"
ANDROID_NDK_TAR="android-ndk-r${ANDROID_NDK_VERSION}b-linux.zip"
ANDROID_NDK_DOWNLOAD="https://dl.google.com/android/repository/$ANDROID_NDK_TAR"

pushd "$DOWNLOADS"
curl -LO "$ANDROID_NDK_DOWNLOAD"
popd
unzip "$DOWNLOADS/$ANDROID_NDK_TAR" -d "$TOOLS"

