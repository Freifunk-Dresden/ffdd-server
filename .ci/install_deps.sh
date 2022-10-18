#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export TZ=Etc/UTC

apt update -y
apt install -y git gettext curl wget time rsync jq \
	nodejs build-essential devscripts debhelper dh-python libssl-dev libncurses5-dev unzip gawk zlib1g-dev subversion gcc-multilib flex \
	libjson-c-dev clang lua5.1 liblua5.1-dev cmake

exit 0
