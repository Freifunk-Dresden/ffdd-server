#!/usr/bin/env bash

mkdir build/ ; cd build

git clone https://github.com/Freifunk-Dresden/ffdd-bmxd.git bmxd
cd bmxd
git checkout latest_server

ARCH='amd64'
VERSION="$(grep -R 'SOURCE_VERSION' batman.h | awk '/SOURCE_VERSION/ {print $3}' | sed -e 's/^"//' -e 's/"$//')"

chmod 755 DEBIAN
chmod 555 DEBIAN/*

make

mkdir -p OUT/usr/sbin/
cp bmxd OUT/usr/sbin/
cp -RPfv DEBIAN OUT/

cd OUT
sed -i "s/ARCH/$ARCH/g" DEBIAN/control
sed -i "s/VERSION/$VERSION/g" DEBIAN/control
md5sum "$(find . -type f | grep -v '^[.]/DEBIAN/')" > DEBIAN/md5sums

dpkg-deb --build ./ /builds/firmware-developer/ffdd-server/.ci/build/bmxd-"$VERSION"_"$ARCH".deb
ls -lah

exit 0
