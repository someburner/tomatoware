#!/bin/bash

__THISDIR=`dirname "$0"`;
source $__THISDIR/versions.sh;

set -e
set -x

export BASE=`pwd`
export SRC=$BASE/src
export PATCHES=$BASE/patches

GCCVER="8.2.0"
UCLIBCVER=${VMAP[uclibc]}
BUILDROOTVER=${VMAP[buildroot]}
TOOLCHAINDIR="/opt/tomatoware/$DESTARCH-$FLOAT${PREFIX////-}"


if [[ ! -d /opt/tomatoware ]]; then
	sudo mkdir -p /opt/tomatoware
	sudo chmod -R 777 /opt/tomatoware
fi


if [[ -f $TOOLCHAINDIR/bin/$DESTARCH-linux-gcc ]]; then
	UCLIBCTEST="$(find $TOOLCHAINDIR -name 'libuClibc*' -exec basename {} \;)"
	UCLIBCTEST=${UCLIBCTEST#libuClibc-}
	UCLIBCTEST=${UCLIBCTEST%.so}
	GCCTEST="$($TOOLCHAINDIR/bin/$DESTARCH-linux-gcc -dumpversion)"

	if [[ "$GCCTEST" != "$GCCVER" ]] || [[ "$UCLIBCTEST" != "$UCLIBCVER" ]]; then
		echo "WARNING: Out of date toolchain detected. Please run \"make toolchain-clean\" and re-run to create new toolchain."
		exit 1
	fi
fi

if ! [[ -f $TOOLCHAINDIR/bin/$DESTARCH-linux-gcc ]]; then
	mkdir $BASE/toolchain
	tar xjf $SRC/toolchain/buildroot-${BUILDROOTVER}.tar.bz2 -C $BASE/toolchain
	cp $SRC/toolchain/defconfig.$DESTARCH $BASE/toolchain/buildroot-${BUILDROOTVER}/defconfig
	cp -r $SRC/toolchain/patches $BASE/toolchain
	mv $BASE/toolchain/patches/linux-headers.$DESTARCH $BASE/toolchain/patches/linux-headers
	echo "UCLIBC_HAS_BACKTRACE=y" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config
	echo "UCLIBC_HAS_FTS=y" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config
	echo "# UCLIBC_USE_MIPS_PREFETCH is not set" >> $BASE/toolchain/buildroot-${BUILDROOTVER}/package/uclibc/uClibc-ng.config
	echo "applying patches";
	sed -i 's,\/opt,'"$PREFIX"',g' \
	$BASE/toolchain/patches/uclibc/001-uclibc-ldso-search-path.patch \
	$BASE/toolchain/patches/uclibc/002-uclibc-ldconfig-opt.patch \
	$BASE/toolchain/patches/uclibc/003-uclibc-dl-defs.patch \
	$BASE/toolchain/patches/uclibc/004-uclibc-ldd-opt.patch
	echo "now in $BASE/toolchain/buildroot-${BUILDROOTVER}"
	cd $BASE/toolchain/buildroot-${BUILDROOTVER}
	make defconfig BR2_DEFCONFIG=defconfig
	make

fi
