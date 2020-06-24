#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###
#
# https://fastd.readthedocs.io/en/stable/index.html
#

LIBUECC_REPO_URL='https://github.com/NeoRaider/libuecc.git'
FASTD_REPO_URL='https://github.com/NeoRaider/fastd.git'


libuecc_rev='7c9a6f6af088d0764e792cf849e553d7f55ff99e'

# fastd v18 (master)
#fastd_rev='8dc1ed3a1ee9af731205a7a4e167c1c2d1b3d819'

# fastd v19
fastd_rev='92bc1c105119c08e340045a157e9bace9a04bb6a'


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
		#-DCMAKE_BUILD_TYPE:STRING=MINSIZEREL

		CMAKE_OPTIONS=" \
		-DCMAKE_BUILD_TYPE=RELEASE \
		-DENABLE_LIBSODIUM:BOOL=FALSE \
		-DENABLE_LTO:BOOL=FALSE \
		-DWITH_CAPABILITIES:BOOL=FALSE \
		-DWITH_MAC_GHASH:BOOL=FALSE \
		-DWITH_CMDLINE_USER:BOOL=FALSE \
		-DWITH_CMDLINE_LOGGING:BOOL=FALSE \
		-DWITH_CMDLINE_OPERATION:BOOL=FALSE \
		-DWITH_CMDLINE_COMMANDS:BOOL=FALSE \
		-DWITH_METHOD_CIPHER_TEST:BOOL=FALSE \
		-DWITH_METHOD_COMPOSED_GMAC:BOOL=FALSE \
		-DWITH_METHOD_GENERIC_GMAC:BOOL=FALSE \
		-DWITH_METHOD_GENERIC_POLY1305:BOOL=FALSE \
		-DWITH_METHOD_NULL:BOOL=TRUE \
		-DWITH_CIPHER_AES128_CTR:BOOL=FALSE \
		-DWITH_CIPHER_NULL:BOOL=TRUE \
		-DWITH_CIPHER_SALSA20:BOOL=FALSE \
		-DWITH_CIPHER_SALSA2012:BOOL=TRUE \
		"

		rm -rf fastd
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
		mkdir build ; cd build
		# shellcheck disable=SC2086
		cmake ../ $CMAKE_OPTIONS
		#cmake ../ -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_LIBSODIUM:BOOL=FALSE -DENABLE_LTO:BOOL=FALSE -DWITH_CAPABILITIES:BOOL=FALSE
		make
		strip src/fastd
		ls -l src/fastd
		make install
	)
}

#needed libs
# nacl: crypt lib wird dazugelinkt (keine shared lib)
apt-get -y install libnacl-dev
apt-get -y install libjson-c-dev

build_libuecc
build_fastd

#check if libuee is found
echo "--------- finished ------------------------"
echo "### call fastd --help"
fastd --help
