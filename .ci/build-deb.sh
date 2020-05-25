#!/usr/bin/env bash

mkdir -p workdir/bmxd

cp -RPvf ../salt/freifunk/base/bmxd/sources/* workdir/bmxd/
cd workdir/bmxd

chmod 755 DEBIAN
chmod 555 DEBIAN/*

make
mkdir -p OUT/usr/sbin/
cp bmxd OUT/usr/sbin/
cp -RPfv DEBIAN OUT/

VERSION=$(git describe --tags | cut -d'-' -f1 | cut -d'_' -f3)
RELEASE=$(git describe --tags --long | cut -d'-' -f 2)

cd OUT
sed -i "s/ARCH/amd64/g" DEBIAN/control
sed -i "s/VERSION/$VERSION/g" DEBIAN/control
sed -i "s/RELEASE/$RELEASE/g" DEBIAN/control
md5sum `find . -type f | grep -v '^[.]/DEBIAN/'` > DEBIAN/md5sums

dpkg-deb --build ./ ../bmxd-$VERSION-$RELEASE.deb
ls -lah
