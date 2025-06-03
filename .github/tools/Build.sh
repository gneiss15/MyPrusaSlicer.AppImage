#!/bin/bash

set -x
set -v

cd "$PRUSA_REPO_DIR"
PACKAGE=PrusaSlicer

# Change Version-Info from ...UNKNOW to ...gneiss15
sed -i "s/UNKNOWN/gneiss15/g" version.inc

# Needed till Eigen Checksum fixed
sed -i "s/URL_HASH.*//g" deps/+Eigen/Eigen.cmake
#sed -i "s/e09b89aae054e9778ee3f606192ee76d645eec82c402c01c648b1fe46b6b9857/4815118c085ff1d5a21f62218a3b2ac62555e9b8d7bacd5093892398e7a92c4b/g" deps/+Eigen/Eigen.cmake

# Download GMP
rm -rf ./deps/build/destdir/*
mkdir -p ./deps/download/GMP
test -r ./deps/download/GMP/gmp-6.2.1.tar.bz2 || curl -o ./deps/download/GMP/gmp-6.2.1.tar.bz2 https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.bz2

# Build dependencies
cd "$PRUSA_REPO_DIR"
cd "deps"
mkdir -p build
cd build
cmake .. -DDEP_WX_GTK3=ON -DDEP_DOWNLOAD_DIR=$(pwd)/../download -DBOOST_ROOT=$(pwd)/../build/destdir/usr/local
make -j $(nproc)

# Build PrusaSlicer
cd "$PRUSA_REPO_DIR"
mkdir -p build
cd build
cmake .. -DSLIC3R_STATIC=1 -DSLIC3R_GTK=3 -DSLIC3R_PCH=OFF -DCMAKE_PREFIX_PATH=$(pwd)/../deps/build/destdir/usr/local -DCMAKE_INSTALL_PREFIX=/usr
make -j $(nproc)
sudo make install
#find ../deps/build/destdir/usr/local

# Vars
DESKTOP=/usr/resources/applications/${PACKAGE}.desktop
ICON=/usr/resources/icons/${PACKAGE}.png
APP_DIR="$PRUSA_REPO_DIR/AppDir"

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1

APPIMAGETOOL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|continuous|*$ARCH.AppImage.zsync"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/tags/v0.4.4/lib4bin"

# Prepare AppDir
cd "$PRUSA_REPO_DIR"
mkdir -p "./AppDir/shared/lib" \
  "./AppDir/usr/share/applications" \
  "./AppDir/etc"

cd "$APP_DIR"

cp -r "/usr/resources"	./usr/

cp "$DESKTOP"		./usr/share/applications
cp "$DESKTOP"		./
cp "$ICON"              ./

ln -s ./usr/share        ./share
ln -s ./usr/resources    ./resources


# ADD LIBRARIES
rm -f ./lib4bin
wget "https://raw.githubusercontent.com/VHSgunzo/sharun/refs/tags/v0.4.4/lib4bin" -O ./lib4bin
chmod +x ./lib4bin
export ARCH="$(uname -m)"
xvfb-run -a -- ./lib4bin -p -v -e -s -k \
  /usr/bin/prusa-slicer \
  /usr/bin/OCCTWrapper.so \
  /usr/lib/"$ARCH"-linux-gnu/libwebkit2gtk* \
  /usr/lib/"$ARCH"-linux-gnu/gdk-pixbuf-*/*/*/* \
  /usr/lib/"$ARCH"-linux-gnu/gio/modules/* \
  /usr/lib/"$ARCH"-linux-gnu/*libnss*.so* \
  /usr/lib/"$ARCH"-linux-gnu/libGL* \
  /usr/lib/"$ARCH"-linux-gnu/libvulkan* \
  /usr/lib/"$ARCH"-linux-gnu/dri/*

# Prusa installs this library in bin normally, so we will place a symlink just in case it is needed
ln -s ../lib/bin/OCCTWrapper.so ./bin/OCCTWrapper.so

# NixOS does not have /usr/lib/locale nor /usr/share/locale, which PrusaSlicer expects
cp -r /usr/lib/locale ./lib/
sed -i -e 's|/usr/lib/locale|././/lib/locale|g' ./bin/prusa-slicer # Since we cannot get LOCPATH to work properly
cp -r /usr/share/locale ./share/
sed -i -e 's|/usr/share/locale|././/share/locale|g' ./shared/lib/libc.so.6 # Since we cannot get LOCPATH to work properly
sed -i -e 's|/usr/lib/locale|././/lib/locale|g' ./shared/lib/libc.so.6  # Since we cannot get LOCPATH to work properly

# Create environment
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}
GSETTINGS_BACKEND=memory
unset LD_LIBRARY_PATH
unset LD_PRELOAD' > ./.env
# LOCPATH=${SHARUN_DIR}/lib/locale:${SHARUN_DIR}/share/locale # This makes PrusaSlicer fail

# Prepare sharun
ln ./sharun ./AppRun
./sharun -g

# Make AppImage with static runtime
cd "$GITHUB_WORKSPACE"
rm -f ./appimagetool
wget -q "$APPIMAGETOOL" -O ./appimagetool
chmod +x ./appimagetool

#UNUSED_APPIMAGETOOL_OPTS=" --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 "
./appimagetool -n -u "$UPINFO" "$APP_DIR" "${THIS_REPO_DIR}/${PACKAGE}-${VERSION}-${ARCH}.AppImage"

rm -rf "$PRUSA_REPO_DIR"

# Upload to GitHub Releases
cd "${THIS_REPO_DIR}"
gh release delete $VERSION -y || true
gh release create $VERSION *.AppImage* --title "$VERSION"

