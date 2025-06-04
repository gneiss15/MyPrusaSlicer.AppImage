#!/bin/bash

#set -x
#set -v

# Build dependencies
mkdir -p "$PRUSA_REPO_DIR/deps/build"
cd "$PRUSA_REPO_DIR/deps/build"
cmake .. -DDEP_WX_GTK3=ON -DDEP_DOWNLOAD_DIR=$(pwd)/../download -DBOOST_ROOT=$(pwd)/../build/destdir/usr/local
make -j $(nproc)

