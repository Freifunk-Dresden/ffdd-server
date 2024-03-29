#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###
#
# https://fastd.readthedocs.io/en/stable/index.html
#

LIBUECC_REPO_URL='https://github.com/NeoRaider/libuecc.git'
FASTD_REPO_URL='https://github.com/NeoRaider/fastd.git'

# libuecc v7
libuecc_rev='7c9a6f6af088d0764e792cf849e553d7f55ff99e'

# fastd v22
fastd_rev='0f47d83eac2047d33efdab6eeaa9f81f17e3ebd1'


build_libuecc()
{
	# make sub shell to avoid extra calles to cd ..
	(
		rm -rf libuecc
		if [ -f libuecc-$libuecc_rev.tgz ]; then
			tar xzf libuecc-"$libuecc_rev".tgz
		else
			git clone "$LIBUECC_REPO_URL" ; cd libuecc
			git checkout "$libuecc_rev" ; cd ..
			rev="$(git -C libuecc log -1 | sed -n '/^commit/s#commit ##p')"
			tar czf libuecc-"$rev".tgz libuecc
		fi
		cd libuecc || exit 1
		mkdir build ; cd build
		cmake ..
		make
		make install
		# call ldconfig to update search path of this lib; else fastd will not find this lib
		ldconfig
	)
}

build_fastd()
{
	(

		CONFIG_OPTIONS=" \
		-Dbuildtype=release \
		-Duse_nacl=true \
		-Db_lto=false \
		-Dcapabilities=disabled \
		-Dmac_ghash=disabled \
		-Dcmdline_user=disabled \
		-Dcmdline_logging=disabled \
		-Dcmdline_operation=disabled \
		-Dcmdline_commands=disabled \
		-Dmethod_cipher-test=disabled \
		-Dmethod_composed-gmac=disabled \
		-Dmethod_generic-gmac=disabled \
		-Dmethod_generic-poly1305=disabled \
		-Dmethod_null=enabled \
		-Dcipher_aes128-ctr=disabled \
		-Dcipher_null=enabled \
		-Dcipher_salsa20=disabled \
		-Dcipher_salsa2012=enabled \
		"

		rm -rf fastd
		rm -rf fastd-build
		if [ -f fastd-$fastd_rev.tgz ]; then
			tar xzf fastd-"$fastd_rev".tgz
		else
			git clone "$FASTD_REPO_URL" ; cd fastd
			git checkout "$fastd_rev" ; cd ..
			rev="$(git -C fastd log -1 | sed -n '/^commit/s#commit ##p')"
			tar czf fastd-"$rev".tgz fastd
		fi

		patch --directory=fastd -p0 < urandom.patch

		cd fastd || exit 1
		cd ..
		meson setup fastd fastd-build $CONFIG_OPTIONS
		cd fastd-build
		ninja
		ninja install

	)
}

#needed libs
# nacl: crypt lib wird dazugelinkt (keine shared lib)
apt-get -y install libnacl-dev
apt-get -y install libjson-c-dev
apt-get -y install meson
apt-get -y install pkg-config

build_libuecc
build_fastd

#check if libuee is found
echo "--------- finished ------------------------"
echo "### call fastd --help"
fastd --help
