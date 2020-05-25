#!/usr/bin/env bash

apt update -y
apt install -y nodejs git build-essential devscripts debhelper dh-systemd python dh-python libssl-dev libncurses5-dev unzip gawk zlib1g-dev subversion gcc-multilib flex gettext curl wget time rsync jq
apt install -y libjson-c-dev clang lua5.1 liblua5.1-dev cmake

mkdir build/ ; cd build

# LIBUBOX
git clone https://git.openwrt.org/project/libubox.git
cd libubox
git checkout 7da66430de3fc235bfc6ebb0b85fb90ea246138d
cd ..

# LIBUCI und UCI
git clone https://git.openwrt.org/project/uci.git
cd uci
git checkout ec8d3233948603485e1b97384113fac9f1bab5d6
cd ..


git clone https://git.openwrt.org/project/ubox.git
git clone https://git.openwrt.org/project/ubus.git

#mkdir BUILD-ubox
#mkdir BUILD-uci

mkdir BUILD-libubox
mkdir BUILD-ubus

#cd BUILD-libubox
#CXX=clang++ CC=clang cmake ../libubox; make; make install

cp -RPvf ../libubox/debian libubox/
cp -RPvf ../uci/debian uci/

cd libubox
debuild -uc -us
cd ..
dpkg -i *.deb

ls -lah

#cd BUILD-uci
#CXX=clang++ CC=clang cmake ../uci; make; make install

cd uci
debuild -uc -us
cd ..
dpkg -i *.deb

cd BUILD-ubus
CXX=clang++ CC=clang cmake ../ubus; make; make install
cd ../BUILD-ubox
cmake ../ubox; make; make install
ldconfig
uci
