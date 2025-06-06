#!/bin/bash

#set -x
#set -v

cd "$PRUSA_REPO_DIR"

# Change Version-Info from ...UNKNOW to ...gneiss15
sed -i "s/UNKNOWN/-gneiss15+UNKNOWN/g" version.inc

# Fixes
if dpkg --compare-versions "$VERSION" "le" "2.9.2"; then
  sed -i "s/URL_HASH.*//g" deps/+Eigen/Eigen.cmake	# Needed till Eigen Checksum fixed
fi
if dpkg --compare-versions "$VERSION" "lt" "2.9.2"; then
  sed -i "s/mpfr-current/mpfr-4.2.1/g" deps/+MPFR/MPFR.cmake
fi
#sed -i "s/e09b89aae054e9778ee3f606192ee76d645eec82c402c01c648b1fe46b6b9857/4815118c085ff1d5a21f62218a3b2ac62555e9b8d7bacd5093892398e7a92c4b/g" deps/+Eigen/Eigen.cmake

# Download/Copy GMP
rm -rf ./deps/build/destdir/*
mkdir -p ./deps/download/GMP
test -r ./deps/download/GMP/gmp-6.2.1.tar.bz2 || cp $TOOLS_DIR/gmp-6.2.1.tar.bz2 ./deps/download/GMP/gmp-6.2.1.tar.bz2
#test -r ./deps/download/GMP/gmp-6.2.1.tar.bz2 || curl -o ./deps/download/GMP/gmp-6.2.1.tar.bz2 https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.bz2


