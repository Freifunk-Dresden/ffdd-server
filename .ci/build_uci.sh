#!/usr/bin/env bash

test ! -d build && mkdir build ; cd build

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

mkdir BUILD-ubus
mkdir BUILD-ubox


cp -RPvf ../libubox/debian libubox/
cp -RPvf ../uci/debian uci/


#mkdir BUILD-libubox
#cd BUILD-libubox
#CXX=clang++ CC=clang cmake ../libubox; make; make install

cd libubox
debuild -uc -us
cd ..
dpkg -i *.deb
ldconfig


#mkdir BUILD-uci
#cd BUILD-uci
#CXX=clang++ CC=clang cmake ../uci; make; make install

cd uci
debuild -uc -us
cd ..
dpkg -i *.deb
ldconfig


cd BUILD-ubus
CXX=clang++ CC=clang cmake ../ubus; make; make install
cd ../BUILD-ubox
cmake ../ubox; make; make install
ldconfig

ls -lah
uci

exit 0
