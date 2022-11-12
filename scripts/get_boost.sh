#!/bin/bash

DOWNLOADS="./downloads/"
SRCS="./srcs/"

mkdir -p "$DOWNLOADS"
mkdir -p "$SRCS"

BOOST_VERSION="${BOOST_VERSION:-1.80.0}"
BOOST_TAR="boost_${BOOST_VERSION//./_}.tar.gz"
BOOST_DOWNLOAD="https://boostorg.jfrog.io/artifactory/main/release/$BOOST_VERSION/source/$BOOST_TAR"

pushd "$DOWNLOADS"
curl -LO "$BOOST_DOWNLOAD"
popd
tar -xvzf "$DOWNLOADS/$BOOST_TAR" -C "$SRCS"

