#!/bin/bash

SRCS="./srcs/"

mkdir -p "$SRCS"

NODE_VERSION="${NODE_VERSION:-18.12.1}"
NODE_TAR="node-v$NODE_VERSION.tar.gz"
NODE_DOWNLOAD="https://nodejs.org/dist/v$NODE_VERSION/$NODE_TAR"

function get_from_tarball() {
  pushd "./downloads/"
  curl -LO "$NODE_DOWNLOAD"
  popd
  tar -xvzf "./downloads/$NODE_TAR" -C "$SRCS"
}

function get_from_git() {
  pushd "$SRCS"
  git clone https://github.com/nodejs/node.git
  cp -r "node" "node-v$NODE_VERSION"
  pushd "node-v$NODE_VERSION"
  git checkout "v$NODE_VERSION"
  popd
  popd
}

get_from_git

