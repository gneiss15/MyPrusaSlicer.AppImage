#!/bin/bash

#set -x
#set -v

# Build PrusaSlicer
mkdir -p "$PRUSA_REPO_DIR/build"
cd "$PRUSA_REPO_DIR/build"
cmake .. -DSLIC3R_STATIC=1 -DSLIC3R_GTK=3 -DSLIC3R_PCH=OFF -DCMAKE_PREFIX_PATH=$(pwd)/../deps/build/destdir/usr/local -DCMAKE_INSTALL_PREFIX=/usr
make -j $(nproc)
sudo make install
#find ../deps/build/destdir/usr/local


