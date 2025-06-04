#!/bin/bash

#set -x
#set -v

echo -e "Binary::apt::APT::Keep-Downloaded-Packages "true";\nAPT::Keep-Downloaded-Packages "true";\n" | sudo tee /etc/apt/apt.conf.d/99x-my

if [ ! -d "$APT_CACHE_DIR" ]; then
  mkdir -p "$APT_CACHE_DIR"
  sudo mv /var/cache/apt/archives/ "$APT_CACHE_DIR"
 else
  echo "$APT_CACHE_DIR exists"
  sudo rm -r /var/cache/apt/archives/
fi
sudo ln -s "$APT_CACHE_DIR/archives/" /var/cache/apt/archives

sudo apt update
# locales-all is needed, otherwise it will crash with LANG=ro_RO.UTF-8
sudo apt install -y locales-all git build-essential autoconf cmake \
  libglu1-mesa-dev libgtk-3-dev libdbus-1-dev libwebkit2gtk-4.1-dev \
  desktop-file-utils libegl-mesa0 libnss-mdns libglx-mesa0 libglx0 \
  libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0 libxcb-sync1 \
  libxcb-xfixes0 libxshmfence1 libgl1 libdrm2 libgbm1 libvulkan1 \
  zlib1g-dev libbz2-dev libboost-all-dev xvfb texinfo \
  file binutils patchelf findutils grep sed coreutils strace

sudo rm -rf $APT_CACHE_DIR/archives/partial/
sudo rm -rf $APT_CACHE_DIR/archives/lock

