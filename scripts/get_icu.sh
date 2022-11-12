#!/bin/bash

DOWNLOADS="./downloads/"

mkdir -p "$DOWNLOADS"

ICU_VERSION=72.1
ICU_TAR=icu4c-${ICU_VERSION//./_}-src.tgz
ICU_DOWNLOAD=https://github.com/unicode-org/icu/releases/download/release-${ICU_VERSION//./-}/$ICU_TAR

pushd "$DOWNLOADS"
curl -LO "$ICU_DOWNLOAD"
popd
tar -xvzf "$DOWNLOADS/$ICU_TAR" -C "$SRCS"

