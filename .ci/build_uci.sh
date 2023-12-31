#!/usr/bin/env bash

test ! -d build && mkdir build ; cd build

# LIBUBOX
git clone https://git.openwrt.org/project/libubox.git
cd libubox || exit 1
git checkout ea56013409d5823001b47a9bba6f74055a6d76a5
cd ..

# LIBUCI und UCI
git clone https://git.openwrt.org/project/uci.git
cd uci || exit 1
git checkout f84f49f00fb70364f58b4cce72f1796a7190d370
cd ..


git clone https://git.openwrt.org/project/ubox.git
# needs to be include udebug for master branch
cd ubox ; git checkout 4c7b720b9c63b826fb9404e454ae54f2ef5649d5 ; cd ..
mkdir BUILD-ubox

git clone https://git.openwrt.org/project/ubus.git
mkdir BUILD-ubus


cp -RPvf ../libubox/debian libubox/
cp -RPvf ../uci/debian uci/


mkdir BUILD-libubox
cd BUILD-libubox
CXX=clang++ CC=clang cmake ../libubox; make; make install
cd ..


mkdir BUILD-uci
cd BUILD-uci
CXX=clang++ CC=clang cmake ../uci; make; make install
cd ..


cd BUILD-ubus
CXX=clang++ CC=clang cmake ../ubus; make; make install
cd ../BUILD-ubox
cmake ../ubox; make; make install

ldconfig
uci
