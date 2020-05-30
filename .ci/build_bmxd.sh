#!/usr/bin/env bash

cd build || mkdir build

git clone https://github.com/Freifunk-Dresden/ffdd-bmxd.git bmxd
cd bmxd || exit 1
git checkout latest_server

chmod 755 DEBIAN
chmod 555 DEBIAN/*

make

ARCH='amd64'
VERSION="$(awk '/SOURCE_VERSION/ {print $3}' batman.h | head -1 | sed -e 's/^"//' -e 's/"$//' -e 's/-freifunk-dresden//')"
REVISION="$(test -f /tmp/bmxd_revision && cat /tmp/bmxd_revision || echo 0)"

mkdir -p OUT/usr/sbin/
cp bmxd OUT/usr/sbin/
cp -RPfv DEBIAN OUT/

cd OUT
sed -i "s/ARCH/$ARCH/g" DEBIAN/control
sed -i "s/VERSION/$VERSION/g" DEBIAN/control
sed -i "s/REVISION/$REVISION/g" DEBIAN/control
md5sum "$(find . -type f | grep -v '^[.]/DEBIAN/')" > DEBIAN/md5sums

dpkg-deb --build ./ ../../bmxd-"$VERSION"-"$REVISION"_"$ARCH".deb

exit 0
