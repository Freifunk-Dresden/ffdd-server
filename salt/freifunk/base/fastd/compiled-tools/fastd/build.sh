#!/bin/bash
### This file managed by Salt, do not edit by hand! ###
#
# fastd + libuecc
# https://projects.universe-factory.net/projects/fastd/wiki/Building
# https://projects.universe-factory.net/projects/fastd/files
#
# git: fastd
# http://git.universe-factory.net/fastd/
# git: libuecc
# http://git.universe-factory.net/libuecc/
#
# nacl: crypt lib wird dazugelinkt (keine shared lib)
# apt-get install libnacl-dev

# fastd v17
#fastd_rev=0358cbf937ee73447970546290a01f82c450dab9
#libuecc_rev=bb4fcb93282ca2c3440294683c88e8d54a1278e0

# fastd v18+ (devel)
#fastd_rev=3995adf7882a43d4c7c206a1c5335e3fdbc9c529
#libuecc_rev=7c9a6f6af088d0764e792cf849e553d7f55ff99e
# 2019 fix
fastd_rev=7d9f90ebe9dd3a7f6af1fbb97d8cc228fb0fded4
libuecc_rev=7c9a6f6af088d0764e792cf849e553d7f55ff99e


build_libuecc()
{
	# make sub shell to avoid extra calles to cd ..
	(
		rm -rf libuecc
		if [ -f libuecc-$libuecc_rev.tgz ]; then
			tar xzf libuecc-$libuecc_rev.tgz
		else
			git clone git://git.universe-factory.net/libuecc
			git checkout $libuecc_rev
			rev=$(git -C libuecc log -1 | sed -n '/^commit/s#commit ##p')
			tar czf libuecc-$rev.tgz libuecc
		fi
		cd libuecc
		mkdir build
		cd build
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
		-DWITH_VERIFY:BOOL=FALSE \
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
		-DWITH_METHOD_XSALSA20_POLY1305:BOOL=FALSE \
		-DWITH_CIPHER_AES128_CTR:BOOL=FALSE \
		-DWITH_CIPHER_NULL:BOOL=TRUE \
		-DWITH_CIPHER_SALSA20:BOOL=FALSE \
		-DWITH_CIPHER_SALSA2012:BOOL=TRUE \
		"

		rm -rf fastd
		if [ -f fastd-$fastd_rev.tgz ]; then
			tar xzf fastd-$fastd_rev.tgz
		else
			git clone git://git.universe-factory.net/fastd
			git checkout $fastd_rev
			rev=$(git -C fastd log -1 | sed -n '/^commit/s#commit ##p')
			tar czf fastd-$rev.tgz fastd
		fi

		patch --directory=fastd -p0 < urandom.patch

		cd fastd
		mkdir build
		cd build
		cmake ../ $CMAKE_OPTIONS
		#cmake ../ -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_LIBSODIUM:BOOL=FALSE -DENABLE_LTO:BOOL=FALSE -DWITH_CAPABILITIES:BOOL=FALSE
		make
		strip src/fastd
		ls -l src/fastd
		make install
	)
}

#needed libs
apt-get -y install libnacl-dev
apt-get -y install libjson-c-dev

build_libuecc
build_fastd

#check if libuee is found
echo "--------- finished ------------------------"
echo "### call fastd --help"
fastd --help
