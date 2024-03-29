#!/usr/bin/env bash

test ! -d build && mkdir build ; cd build

# LIBUBOX
git clone https://git.openwrt.org/project/libubox.git
cd libubox || exit 1
git checkout ea56013409d5823001b47a9bba6f74055a6d76a5
cd .. ; mkdir BUILD-libubox

# UCI
git clone https://git.openwrt.org/project/uci.git
cd uci || exit 1
git checkout f84f49f00fb70364f58b4cce72f1796a7190d370
cd .. ; mkdir BUILD-uci

# UBOX
git clone https://git.openwrt.org/project/ubox.git
# needs to be include udebug for master branch
cd ubox || exit 1
git checkout 4c7b720b9c63b826fb9404e454ae54f2ef5649d5
cd .. ; mkdir BUILD-ubox

# UBUS
git clone https://git.openwrt.org/project/ubus.git
mkdir BUILD-ubus


# copy debuild deps.
cp -RPvf ../libubox/debian libubox/
cp -RPvf ../uci/debian uci/


cd BUILD-libubox
CXX=clang++ CC=clang cmake ../libubox; make; make install
cd ..

cd libubox
debuild -uc -us
cd ..
dpkg -i ./*.deb


cd BUILD-uci
CXX=clang++ CC=clang cmake ../uci; make; make install
cd ..

cd uci
debuild -uc -us
cd ..
dpkg -i ./*.deb


cd BUILD-ubus
CXX=clang++ CC=clang cmake ../ubus; make; make install
cd ../BUILD-ubox
cmake ../ubox; make; make install


ldconfig
uci
