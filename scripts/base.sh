#!/bin/bash
__THISDIR=`dirname "$0"`

# Print commands and their arguments as they are executed.
#set -x

# Exit upon error
set -e

#TODO: checks for installed tools
#apt install libtool-bin

BASE=`pwd`
SRC=$BASE/src
PATCHES=$BASE/patches
RPATH=$PREFIX/lib
DEST=$BASE$PREFIX
LDFLAGS="-L$DEST/lib -s -Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 -Wl,-rpath,$RPATH -Wl,-rpath-link,$DEST/lib"
CPPFLAGS="-I$DEST/include"
CFLAGS=$EXTRACFLAGS
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=$PREFIX --host=$DESTARCH-linux"
MAKE="make -j`nproc`"
unset LS_COLORS

################################ Base Loop ################################
source $__THISDIR/base_lists.sh;
source $__THISDIR/package/utils.sh;
#BASELIST="FULL"
BASELIST="MINI"

# base_main "FULL"/"MINI"
base_main() {
	local m; local n; local a;
	typeset -n a="BASE_$1";
	typeset -n BOOST_LIBS="BOOST_$1_LIBS";

	((n=${#a[@]},m=n-1));
	paintln "wht" "Using list=$1"
	for ((i=0;i<=m;i++)); do
		do_warn "do_${a[i]}";
		eval "do_${a[i]}";
	done;
	do_okay "base_main - done"
	return 0;
}
################################ Base Loop ################################



######### ###################################################################
# BZIP2 # ###################################################################
######### ###################################################################
do_BZIP2() {
BZIP2_VERSION=1.0.6

cd $SRC/bzip2

if ! [[ -f .extracted ]]; then
	rm -rf bzip2-${BZIP2_VERSION}
	tar xzf bzip2-${BZIP2_VERSION}.tar.gz
	touch .extracted
fi

cd bzip2-${BZIP2_VERSION}

if ! [[ -f .patched ]]; then
	patch < $PATCHES/bzip2/bzip2.patch
	patch < $PATCHES/bzip2/bzip2_so.patch
	touch .patched
fi

if ! [[ -f .built ]]; then
	$MAKE
	$MAKE -f Makefile-libbz2_so
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install PREFIX=$DEST
	touch .installed
fi
}

######### ###################################################################
# LBZIP2 # ###################################################################
######### ###################################################################
do_LBZIP2() {
LBZIP2_VERSION=2.5

cd $SRC/lbzip2

if ! [[ -f .extracted ]]; then
	rm -rf lbzip2-${LBZIP2_VERSION}
	tar xzf lbzip2-${LBZIP2_VERSION}.tar.gz
	touch .extracted
fi

cd lbzip2-${LBZIP2_VERSION}

if ! [[ -f .configured ]]; then
        LDFLAGS=$LDFLAGS \
        CPPFLAGS=$CPPFLAGS \
        CFLAGS=$CFLAGS \
        CXXFLAGS=$CXXFLAGS \
        $CONFIGURE \
	--prefix=$PREFIX
        touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
        make install DESTDIR=$BASE
        touch .installed
fi
}

######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################
do_ZLIB() {
ZLIB_VERSION=1.2.11

cd $SRC/zlib

if ! [[ -f .extracted ]]; then
	rm -rf zlib-${ZLIB_VERSION}
	tar xzf zlib-${ZLIB_VERSION}.tar.gz
	touch .extracted
fi

cd zlib-${ZLIB_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	CROSS_PREFIX=$DESTARCH-linux- \
	./configure \
	--prefix=$PREFIX
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

####### #####################################################################
# LZO # #####################################################################
####### #####################################################################
do_LZO() {
LZO_VERSION=2.10

cd $SRC/lzo

if ! [[ -f .extracted ]]; then
	rm -rf lzo-${LZO_VERSION}
	tar xzf lzo-${LZO_VERSION}.tar.gz
	touch .extracted
fi

cd lzo-${LZO_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-shared=yes
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

############ ################################################################
# XZ_UTILS # ################################################################
############ ################################################################
do_XZ_UTILS() {
XZ_UTILS_VERSION=5.2.4

cd $SRC/xz

if ! [[ -f .extracted ]]; then
	rm -rf xz-${XZ_UTILS_VERSION}
	tar xjf xz-${XZ_UTILS_VERSION}.tar.bz2
	touch .extracted
fi

cd xz-${XZ_UTILS_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	libtoolize && \
	$CONFIGURE --prefix=$PREFIX
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################
do_OPENSSL() {
OPENSSL_VERSION=1.0.2p

cd $SRC/openssl

if ! [[ -f .extracted ]]; then
	rm -rf openssl-${OPENSSL_VERSION}
	tar xjf openssl-${OPENSSL_VERSION}.tar.bz2
	touch .extracted
fi

cd openssl-${OPENSSL_VERSION}

[[ "$DESTARCH" == "mipsel" ]] && os=linux-mips32

[[ "$DESTARCH" == "arm" ]] && os="linux-armv4 -march=armv7-a -mtune=cortex-a9"

if ! [[ -f .configured ]]; then
	./Configure $os \
	-Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 \
	-Wl,-rpath,$RPATH -Wl,-rpath-link=$RPATH \
	--prefix=$PREFIX shared zlib \
	--with-zlib-lib=$DEST/lib \
	--with-zlib-include=$DEST/include
	touch .configured
fi

if ! [[ -f .built ]]; then
	make CC=$DESTARCH-linux-gcc
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install CC=$DESTARCH-linux-gcc INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl
	touch .installed
fi
}

############ ################################################################
# LIBICONV # ################################################################
############ ################################################################
do_LIBICONV() {
LIBICONV_VERSION=1.15

cd $SRC/libiconv

if ! [[ -f .extracted ]]; then
	rm -rf libiconv-${LIBICONV_VERSION}
	tar xzf libiconv-${LIBICONV_VERSION}.tar.gz
	touch .extracted
fi

cd libiconv-${LIBICONV_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE --prefix=$PREFIX --enable-static
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########### #################################################################
# GETTEXT # #################################################################
########### #################################################################
do_GETTEXT() {
GETTEXT_VERSION=0.19.8.1

cd $SRC/gettext

if ! [[ -f .extracted ]]; then
	rm -rf gettext-${GETTEXT_VERSION}
	tar xzf gettext-${GETTEXT_VERSION}.tar.gz
	touch .extracted
fi

cd gettext-${GETTEXT_VERSION}

if ! [[ -f .patched ]]; then
	patch -p1 < $PATCHES/gettext/spawn.patch
	touch .patched
fi

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if ! [[ -f .edit_sed ]]; then
	sed -i 's,'"$PREFIX"'\/lib\/libiconv.la,'"$DEST"'\/lib\/libiconv.la,g' \
	$DEST/lib/libintl.la
	touch .edit_sed
fi
}

######## ####################################################################
# FLEX # ####################################################################
######## ####################################################################
do_FLEX() {
FLEX_VERSION=2.6.0

cd $SRC/flex

if ! [[ -f .extracted ]]; then
	rm -rf flex-${FLEX_VERSION}
	tar xzf flex-${FLEX_VERSION}.tar.gz
	touch .extracted
fi

cd flex-${FLEX_VERSION}

if ! [[ -f .patched ]]; then
	sed -i '/tests/d' Makefile.in
	touch .patched
fi

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

######## ####################################################################
# CURL # ####################################################################
######## ####################################################################
do_CURL() {
CURL_VERSION=7.62.0

cd $SRC/curl

if ! [[ -f .extracted ]]; then
	rm -rf curl-${CURL_VERSION}
	tar xjf curl-${CURL_VERSION}.tar.bz2
	touch .extracted
fi

cd curl-${CURL_VERSION}

if ! [[ -f .configured ]]; then
	PKG_CONFIG_PATH="$DEST/lib/pkgconfig" \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-ssl=$DEST \
	--with-ca-path=$PREFIX/ssl/certs
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if ! [[ -f .certs_installed ]]; then
	mkdir -p $DEST/ssl/certs
	cd $DEST/ssl/certs
	curl https://curl.haxx.se/ca/cacert.pem | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".pem"}'
	c_rehash .
	touch $SRC/curl/curl-${CURL_VERSION}/.certs_installed
fi
}

######### ###################################################################
# EXPAT # ###################################################################
######### ###################################################################
do_EXPAT() {
EXPAT_VERSION=2.2.5

cd $SRC/expat

if ! [[ -f .extracted ]]; then
	rm -rf cd expat-${EXPAT_VERSION}
	tar xjf expat-${EXPAT_VERSION}.tar.bz2
	touch .extracted
fi

cd expat-${EXPAT_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS  \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########### #################################################################
# LIBPCAP # #################################################################
########### #################################################################
do_LIBPCAP() {
LIBPCAP_VERSION=1.9.0

cd $SRC/libpcap

if ! [[ -f .extracted ]]; then
	rm -rf libpcap-${LIBPCAP_VERSION}
	tar xjf libpcap-${LIBPCAP_VERSION}.tar.bz2
	touch .extracted
fi

cd libpcap-${LIBPCAP_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-pcap=linux \
	--enable-ipv6
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########## ##################################################################
# LIBFFI # ##################################################################
########## ##################################################################
do_LIBFFI() {
LIBFFI_VERSION=3.2.1

cd $SRC/libffi

if ! [[ -f .extracted ]]; then
	rm -rf libffi-${LIBFFI_VERSION}
	tar xzf libffi-${LIBFFI_VERSION}.tar.gz
	touch .extracted
fi

cd libffi-${LIBFFI_VERSION}

if ! [[ -f .patched ]] && [[ "$DESTARCH" == "mipsel" ]]; then
	patch -p1 < $PATCHES/libffi/mips.softfloat.patch
	touch .patched
fi

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########### #################################################################
# NCURSES # #################################################################
########### #################################################################
do_NCURSES() {
NCURSES_VERSION=6.1

cd $SRC/ncurses

if ! [[ -f .extracted ]]; then
	rm -rf ncurses-${NCURSES_VERSION}
	tar xzf ncurses-${NCURSES_VERSION}.tar.gz
	touch .extracted
fi

cd ncurses-${NCURSES_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="-P $CPPFLAGS" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-widec \
	--enable-overwrite \
	--with-normal \
	--with-shared \
	--enable-rpath \
	--with-fallbacks=xterm \
	--without-progs
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if ! [[ -f .linked ]]; then
	ln -sf libncursesw.a $DEST/lib/libncurses.a
	ln -sf libncursesw.so $DEST/lib/libncurses.so
	ln -sf libncursesw.so.6 $DEST/lib/libncurses.so.6
	ln -sf libncursesw.so.6.0 $DEST/lib/libncurses.so.6.0
	ln -sf libncurses++w.a $DEST/lib/libncurses++.a
	ln -sf libncursesw_g.a $DEST/lib/libncurses_g.a
	ln -sf libncursesw.a $DEST/lib/libcurses.a
	ln -sf libncursesw.so $DEST/lib/libcurses.so
	ln -sf libcurses.so $DEST/lib/libtinfo.so
	touch .linked
fi
}

############### #############################################################
# LIBREADLINE # #############################################################
############### #############################################################
do_LIBREADLINE() {
LIBREADLINE_VERSION=7.0

cd $SRC/libreadline

if ! [[ -f .extracted ]]; then
	rm -rf readline-${LIBREADLINE_VERSION}
	tar xzf readline-${LIBREADLINE_VERSION}.tar.gz
	touch .extracted
fi

cd readline-${LIBREADLINE_VERSION}

if ! [[ -f .patched ]]; then
	patch < $PATCHES/readline/readline.patch
	touch .patched
fi

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	bash_cv_wcwidth_broken=no \
	bash_cv_func_sigsetjmp=yes
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########### #################################################################
# LIBGDBM # #################################################################
########### #################################################################
do_LIBGDBM() {
LIBGDBM_VERSION=1.14.1

cd $SRC/libgdbm

if ! [[ -f .extracted ]]; then
	rm -rf gdbm-${LIBGDBM_VERSION}
	tar xzf gdbm-${LIBGDBM_VERSION}.tar.gz
	touch .extracted
fi

cd gdbm-${LIBGDBM_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

####### #####################################################################
# TCL # #####################################################################
####### #####################################################################
do_TCL() {
TCL_VERSION=8.6.8

cd $SRC/tcl

if ! [[ -f .extracted ]]; then
	rm -rf cd tcl${TCL_VERSION}/unix
	tar xzf tcl${TCL_VERSION}-src.tar.gz
	touch .extracted
fi

cd tcl${TCL_VERSION}/unix

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-threads \
	--enable-shared \
	--enable-symbols \
	ac_cv_func_strtod=yes \
	tcl_cv_strtod_buggy=1
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

####### #####################################################################
# BDB # #####################################################################
####### #####################################################################
do_BDB() {
BDB_VERSION=4.7.25

cd $SRC/bdb

if ! [[ -f .extracted ]]; then
	rm -rf db-${BDB_VERSION}
	tar xzf db-${BDB_VERSION}.tar.gz
	touch .extracted
fi

cd  db-${BDB_VERSION}/build_unix

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	../dist/$CONFIGURE \
	--enable-cxx \
	--enable-tcl \
	--enable-compat185 \
	--with-tcl=$DEST/lib
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########## ##################################################################
# SQLITE # ##################################################################
########## ##################################################################
do_SQLITE() {
SQLITE_VERSION=3250300

cd $SRC/sqlite

if ! [[ -f .extracted ]]; then
	rm -rf sqlite-autoconf-${SQLITE_VERSION}
	tar xzf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
	touch .extracted
fi

cd sqlite-autoconf-${SQLITE_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	make
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

#############################################################################
# LIBXML - Depends: lzma (do_XZ_UTILS), z (do_ZLIB)
#############################################################################
do_LIBXML() {
LIBXML2_VERSION=2.9.8

cd $SRC/libxml2

if ! [[ -f .extracted ]]; then
	rm -rf libxml2-${LIBXML2_VERSION}
	tar xzf libxml2-${LIBXML2_VERSION}.tar.gz
	touch .extracted
fi

cd libxml2-${LIBXML2_VERSION}

if ! [[ -f .configured ]]; then
	Z_CFLAGS=-I$DEST/include \
	Z_LIBS=-L$DEST/lib \
	LDFLAGS="-lz -llzma $LDFLAGS" \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-python \
	--with-zlib=$BASE \
	--with-lzma=$BASE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi

if ! [[ -f .edit_sed ]]; then
	sed -i 's,'"$PREFIX"'\/lib\/libiconv.la,'"$DEST"'\/lib\/libiconv.la,g' \
	$DEST/lib/libxml2.la
	touch .edit_sed
fi

if ! [[ -f .edit_sed2 ]]; then
	sed -i 's,'"$PREFIX"'\/lib\/liblzma.la,'"$DEST"'\/lib\/liblzma.la,g' \
	$DEST/lib/libxml2.la
	touch .edit_sed2
fi
}

########### #################################################################
# LIBXSLT # #################################################################
########### #################################################################
do_LIBXSLT() {
LIBXSLT_VERSION=1.1.32

cd $SRC/libxslt

if ! [[ -f .extracted ]]; then
	rm -rf libxslt-${LIBXSLT_VERSION}
	tar xzf libxslt-${LIBXSLT_VERSION}.tar.gz
	touch .extracted
fi

cd libxslt-${LIBXSLT_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-libxml-src=$SRC/libxml2/libxml2-${LIBXML2_VERSION} \
	--without-python \
	--without-crypto
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

############# ###############################################################
# LIBSIGC++ # ###############################################################
############# ###############################################################
do_LIBSIGCpp() {
LIBSIGCPLUSPLUS_VERSION=2.4.1

cd $SRC/libsigc++

if ! [[ -f .extracted ]]; then
	rm -rf libsigc++-${LIBSIGCPLUSPLUS_VERSION}
	tar xJf libsigc++-${LIBSIGCPLUSPLUS_VERSION}.tar.xz
	touch .extracted
fi

cd libsigc++-${LIBSIGCPLUSPLUS_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-static
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########### #################################################################
# LIBPAR2 # #################################################################
########### #################################################################
do_LIBPAR2() {
LIBPAR2_VERSION=0.4

export PKG_CONFIG_LIBDIR=$DEST/lib/pkgconfig

cd $SRC/libpar2

if ! [[ -f .extracted ]]; then
	rm -rf libpar2-${LIBPAR2_VERSION}
	tar xzf libpar2-${LIBPAR2_VERSION}.tar.gz
	touch .extracted
fi

cd libpar2-${LIBPAR2_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="$CPPFLAGS -I$DEST/include/sigc++-2.0 -I$DEST/lib/sigc++-2.0/include" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi

unset PKG_CONFIG_LIBDIR
}

############ ################################################################
# LIBEVENT # ################################################################
############ ################################################################
do_LIBEVENT() {
LIBEVENT_VERSION=2.0.22

cd $SRC/libevent

if ! [[ -f .extracted ]]; then
	rm -rf libevent-${LIBEVENT_VERSION}-stable
	tar xzf libevent-${LIBEVENT_VERSION}-stable.tar.gz
	touch .extracted
fi

cd libevent-${LIBEVENT_VERSION}-stable

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

################## ##########################################################
# LIBMYSQLCLIENT # ##########################################################
################## ##########################################################
do_LIBMYSQLCLIENT() {
LIBMYSQLCLIENT_VERSION=6.1.6

cd $SRC/libmysqlclient

if ! [[ -f .extracted ]]; then
	rm -rf mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src-native
	tar xzf mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src.tar.gz
	cp -r mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src-native
	touch .extracted
fi

cd mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src-native

if ! [[ -f .built_native ]]; then
	cmake .
	make
	touch .built_native
fi

cd ../mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src

if ! [[ -f .patched ]]; then
	patch -p1 < $PATCHES/libmysqlclient/libmysqlclient.patch
	touch .patched
fi

if ! [[ -f .configured ]]; then
	cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DINSTALL_INCLUDEDIR=include/mysql \
	-DCMAKE_C_COMPILER=`which $DESTARCH-linux-gcc` \
	-DCMAKE_CXX_COMPILER=`which $DESTARCH-linux-g++` \
	-DHAVE_GCC_ATOMIC_BUILTINS=1 \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
	./
	touch .configured
fi

if ! [[ -f .built ]]; then
	make || true
	cp ../mysql-connector-c-${LIBMYSQLCLIENT_VERSION}-src-native/extra/comp_err ./extra/comp_err
	make
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	cp -r $DEST/include/mysql/mysql/ $DEST/include/
	rm -rf $DEST/include/mysql/mysql
	touch .installed
fi
}

######## ####################################################################
# PERL # ####################################################################
######## ####################################################################
do_PERL() {
PERL_VERSION='5.27.11'
PERL_CROSS_VERSION='1.1.9'

cp -f /usr/bin/perl /tmp/sysperl
cp -f /usr/bin/perl /tmp/sysperl-backup

cd $SRC/perl

if ! [[ -f .extracted ]]; then
	rm -rf perl-${PERL_VERSION}
	tar -xjf perl-${PERL_VERSION}.tar.bz2
	cd perl-${PERL_VERSION}
	tar --strip-components=1 -xjf ../perl-cross-${PERL_CROSS_VERSION}.tar.bz2
	#--strip 1
	cd ..
	touch .extracted
fi

cd perl-${PERL_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS="-Wl,--dynamic-linker=$PREFIX/lib/ld-uClibc.so.1 -Wl,-rpath,$RPATH" \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure --target=$DESTARCH-linux --use-threads --prefix=$PREFIX -Duseshrplib
	! [[ $? -eq 0 ]] && (cd .. && rm -rf perl-${PERL_VERSION} && rm -f .extracted) && exit 1;
	touch .configured
fi

if ! [[ -f .built ]]; then
	make
	touch .built
fi

if ! [[ -f .installed ]]; then
	rm -f $BASE$PREFIX/lib/libperl.so $BASE$PREFIX/bin/perl
	cd $SRC/perl/perl-${PERL_VERSION}
	make DESTDIR="$BASE" install
	cd $BASE$PREFIX/lib && \
		ln -s perl5/${PERL_VERSION}/arm-linux/CORE/libperl.so libperl.so
	rm -f $BASE$PREFIX/bin/perl
	sleep "0.5";
	cp -f /usr/bin/perl $BASE$PREFIX/bin/perl
	sleep "0.5";
	rm -f /usr/bin/perl
	sleep "0.5";
	cp -f /tmp/sysperl /usr/bin/perl
	cd $SRC/perl/perl-${PERL_VERSION}
	touch .installed
fi

}

######## ####################################################################
# PCRE # ####################################################################
######## ####################################################################
do_PCRE() {
PCRE_VERSION=8.42

cd $SRC/pcre

if ! [[ -f .extracted ]]; then
	rm -rf pcre-${PCRE_VERSION}
	tar xjf pcre-${PCRE_VERSION}.tar.bz2
	touch .extracted
fi

cd pcre-${PCRE_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-pcregrep-libz \
	--enable-pcregrep-bzip2 \
	--enable-pcretest-libreadline \
	--enable-unicode-properties \
	--enable-jit
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########## ##################################################################
# PYTHON # ##################################################################
########## ##################################################################
do_PYTHON27() {
PYTHON_VERSION=2.7.3

cd $SRC/python

if ! [[ -f .extracted ]]; then
	rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}-native
	tar xzf Python-${PYTHON_VERSION}.tgz
	cp -r Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}-native
	touch .extracted
fi

cd Python-${PYTHON_VERSION}-native

if ! [[ -f .patched_native ]]; then
	patch -p1 < $PATCHES/python/python_asdl.patch
	touch .patched_native
fi

if ! [[ -f .built_native ]]; then
	./configure
	$MAKE
	touch .built_native
fi

cd ../Python-${PYTHON_VERSION}

if ! [[ -f .patched ]]; then
	patch < $PATCHES/python/python-drobo.patch
	patch -p1 < $PATCHES/python/python_asdl.patch
	patch -p1 < $PATCHES/python/002_readline63.patch
	touch .patched
fi

if ! [[ -f .configured ]]; then
	CC=$DESTARCH-linux-gcc \
	CXX=$DESTARCH-linux-g++ \
	AR=$DESTARCH-linux-ar \
	RANLIB=$DESTARCH-linux-ranlib \
	LDFLAGS=$LDFLAGS \
	CPPFLAGS="-I$DEST/lib/libffi-3.2.1/include $CPPFLAGS" \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--build=`uname -m`-linux-gnu \
	--with-dbmliborder=gdbm:bdb \
	--with-threads \
	--with-system-ffi \
	--enable-shared
	touch .configured
fi

if ! [[ -f .copied ]]; then
	cp ../Python-${PYTHON_VERSION}-native/python ./hostpython
	cp ../Python-${PYTHON_VERSION}-native/Parser/pgen Parser/hostpgen
	touch .copied
fi

if ! [[ -f .built ]]; then
	$MAKE \
	HOSTPYTHON=./hostpython \
	HOSTPGEN=./Parser/hostpgen \
	CROSS_COMPILE=$DESTARCH-linux- \
	CROSS_COMPILE_TARGET=yes \
	HOSTDESTARCH=$DESTARCH-linux \
	BUILDDESTARCH=`uname -m`-linux-gnu
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install \
	DESTDIR=$BASE \
	HOSTPYTHON=../Python-${PYTHON_VERSION}-native/python \
	CROSS_COMPILE=$DESTARCH-linux- \
	CROSS_COMPILE_TARGET=yes
	touch .installed
fi

cd $SRC/python/Python-${PYTHON_VERSION}/build/

if ! [[ -f .rename_and_move ]]; then
	mv lib.linux-`uname -m`-2.7/ lib.linux-$DESTARCH-2.7/
	cp -R ../../Python-${PYTHON_VERSION}-native/build/lib.linux-`uname -m`-2.7/ .
	touch .rename_and_move
fi
}

########### #################################################################
# CHEETAH # #################################################################
########### #################################################################
do_CHEETAH() {
CHEETAH_VERSION=3.0.0

cd $SRC/cheetah

if ! [[ -f .extracted ]]; then
	rm -rf Cheetah3-${CHEETAH_VERSION}
	tar xzf Cheetah3-${CHEETAH_VERSION}.tar.gz
	touch .extracted
fi

cd Cheetah3-${CHEETAH_VERSION}

if ! [[ -f .built ]]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	./setup.py \
	build
	touch .built
fi

if ! [[ -f .installed ]]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	./setup.py \
	install \
	--prefix=$PREFIX \
	--root=$BASE
	touch .installed
fi
}

######## ####################################################################
# YENC # ####################################################################
######## ####################################################################
do_YENC() {
YENC_VERSION=0.4.0

cd $SRC/yenc

if ! [[ -f .extracted ]]; then
	rm -rf yenc-${YENC_VERSION}
	tar xzf yenc-${YENC_VERSION}.tar.gz
	touch .extracted
fi

cd yenc-${YENC_VERSION}

if ! [[ -f .built ]]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	./setup.py \
	build
	touch .built
fi

if ! [[ -f .installed ]]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	./setup.py \
	install \
	--prefix=$PREFIX \
	--root=$BASE
	touch .installed
fi
}

############# ###############################################################
# pyOpenSSL # ###############################################################
############# ###############################################################
do_pyOpenSSL() {
PYOPENSSL_VERSION=0.13.1

cd $SRC/pyopenssl

if ! [[ -f .extracted ]]; then
	rm -rf pyOpenSSL-${PYOPENSSL_VERSION}
	tar xzf pyOpenSSL-${PYOPENSSL_VERSION}.tar.gz
	touch .extracted
fi

cd pyOpenSSL-${PYOPENSSL_VERSION}

if ! [[ -f .patched ]]; then
	patch -p1 < $PATCHES/pyopenssl/010-openssl.patch
        touch .patched
fi

if ! [[ -f .built ]]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	setup.py \
	build_ext \
	-I$DEST/include \
	-L$DEST/lib \
	-R$RPATH
	touch .built
fi


if ! [[ -f .installed ]]; then
	PYTHONPATH=../../python/Python-${PYTHON_VERSION}/Lib/ \
	../../python/Python-${PYTHON_VERSION}/hostpython \
	setup.py \
	install \
	--prefix=$PREFIX \
	--root=$BASE
	touch .installed
fi
}

############### #############################################################
# PAR2CMDLINE # #############################################################
############### #############################################################
do_PAR2CMDLINE() {
PAR2CMDLINE_VERSION=0.8.0

cd $SRC/par2cmdline

if ! [[ -f .extracted ]]; then
	rm -rf par2cmdline-${PAR2CMDLINE_VERSION}
	tar xzf par2cmdline-${PAR2CMDLINE_VERSION}.tar.gz
	touch .extracted
fi

cd par2cmdline-${PAR2CMDLINE_VERSION}

if ! [[ -f .configured ]]; then
	aclocal
	automake --add-missing
	autoconf
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	make clean
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

######### ###################################################################
# UNRAR # ###################################################################
######### ###################################################################
do_UNRAR() {
UNRAR_VERSION=5.6.8

cd $SRC/unrar

if ! [[ -f .extracted ]]; then
	rm -rf unrar
	tar xzf unrarsrc-${UNRAR_VERSION}.tar.gz
	touch .extracted
fi

cd unrar

if ! [[ -f .patched ]]; then
	patch < $PATCHES/unrar/unrar.patch
	touch .patched
fi

if ! [[ -f .built ]]; then
	make
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$DEST
	touch .installed
fi
}

####### #####################################################################
# GIT # #####################################################################
####### #####################################################################
do_GIT() {
GIT_VERSION=2.19.1

cd $SRC/git

if ! [[ -f .extracted ]]; then
	rm -rf git-${GIT_VERSION}
	tar xjf git-${GIT_VERSION}.tar.bz2
	touch .extracted
fi

cd git-${GIT_VERSION}

if ! [[ -f .built ]]; then
	make distclean
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$MAKE \
	CC=$DESTARCH-linux-gcc \
	AR=$DESTARCH-linux-ar \
	prefix=$PREFIX \
	FREAD_READS_DIRECTORIES=no \
	SNPRINTF_RETURNS_BOGUS=no \
	NO_TCLTK=yes \
	NO_R_TO_GCC_LINKER=yes \
	USE_LIBPCRE1=yes \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -lgettextlib -liconv -lintl -lpcre"
	touch .built
fi

if ! [[ -f .installed ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	make \
	CC=$DESTARCH-linux-gcc \
	AR=$DESTARCH-linux-ar \
	prefix=$PREFIX \
	FREAD_READS_DIRECTORIES=no \
	SNPRINTF_RETURNS_BOGUS=no \
	NO_TCLTK=yes \
	NO_R_TO_GCC_LINKER=yes \
	USE_LIBPCRE1=yes \
	EXTLIBS="$LDFLAGS -lssl -lcrypto -lcurl -lz -lgettextlib -liconv -lintl -lpcre" \
	install DESTDIR=$BASE
	touch .installed
fi
}

########## ##################################################################
# STRACE # ##################################################################
########## ##################################################################
do_STRACE() {
STRACE_VERSION=4.21

cd $SRC/strace

if ! [[ -f .extracted ]]; then
	rm -rf strace-${STRACE_VERSION}
	tar xJf strace-${STRACE_VERSION}.tar.xz
	touch .extracted
fi

cd strace-${STRACE_VERSION}

[[ "$DESTARCH" == "mipsel" ]] && straceconfig=ac_cv_header_linux_dm_ioctl_h=no

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	$straceconfig
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

####### #####################################################################
# PAM # #####################################################################
####### #####################################################################
do_PAM() {
LINUX_PAM_VERSION=1.3.0

cd $SRC/pam

if ! [[ -f .extracted ]]; then
	rm -rf Linux-PAM-${LINUX_PAM_VERSION}
	tar xzf Linux-PAM-${LINUX_PAM_VERSION}.tar.gz
	touch .extracted
fi

cd Linux-PAM-${LINUX_PAM_VERSION}

if ! [[ -f .patched ]]; then
	patch -p1 < $PATCHES/pam/0002-Conditionally-compile-per-ruserok-availability.patch
	find libpam -iname \*.h -exec sed -i 's,\/etc\/pam,'"$PREFIX"'\/etc\/pam,g' {} \;
	aclocal
	automake --add-missing
	autoconf

	touch .patched
fi

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-read-both-confs \
	--disable-nls \
	ac_cv_search_crypt=no
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	sed -i 's,mkdir -p $(namespaceddir),mkdir -p $(DESTDIR)$(namespaceddir),g' \
	modules/pam_namespace/Makefile
	make install DESTDIR=$BASE
	cp -r libpam/include/security/ $DEST/include
	touch .installed
fi
}

########### #################################################################
# OPENSSH # #################################################################
########### #################################################################
do_OPENSSH() {
OPENSSH_VERSION=7.9p1

cd $SRC/openssh

if ! [[ -f .extracted ]]; then
	rm -rf openssh-${OPENSSH_VERSION}
	tar xjf openssh-${OPENSSH_VERSION}.tar.bz2
	touch .extracted
fi

cd openssh-${OPENSSH_VERSION}

if ! [[ -f .patched ]]; then
	patch -p1 < $PATCHES/openssh/openssh-fix-pam-uclibc-pthreads-clash.patch
	touch .patched
fi

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--sysconfdir=$PREFIX/etc/ssh \
	--with-pid-dir=/var/run \
	--with-privsep-path=/var/empty \
	--with-pam
	touch .configured
fi

if ! [[ -f .makefile_patch ]]; then
	patch < $PATCHES/openssh/remove_check-config.patch
	touch .makefile_patch
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE STRIP_OPT="-s --strip-program=$DESTARCH-linux-strip"
	touch .installed
fi
}

######## ####################################################################
# HTOP # ####################################################################
######## ####################################################################
do_HTOP() {
HTOP_VERSION=2.1.0

cd $SRC/htop

if ! [[ -f .extracted ]]; then
	rm -rf htop-${HTOP_VERSION}
	tar xzf htop-${HTOP_VERSION}.tar.gz
	touch .extracted
fi

cd htop-${HTOP_VERSION}

if ! [[ -f .configured ]]; then
	./autogen.sh
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########## ##################################################################
# SCREEN # ##################################################################
########## ##################################################################
do_SCREEN() {
SCREEN_VERSION=4.6.2

cd $SRC/screen

if ! [[ -f .extracted ]]; then
	rm -rf screen-${SCREEN_VERSION}
	tar xzf screen-${SCREEN_VERSION}.tar.gz
	touch .extracted
fi

cd screen-${SCREEN_VERSION}

if ! [[ -f .patched ]]; then
	patch < $PATCHES/screen/screen.patch
	touch .patched
fi

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

######## ####################################################################
# BASH # ####################################################################
######## ####################################################################
do_BASH() {
BASH_VERSION=4.4.23

cd $SRC/bash

if ! [[ -f .extracted ]]; then
	rm -rf bash-${BASH_VERSION}
	tar xzf bash-${BASH_VERSION}.tar.gz
	touch .extracted
fi

cd bash-${BASH_VERSION}

if ! [[ -f .patched ]]; then
	patch < $PATCHES/bash/001-compile-fix.patch
	patch < $PATCHES/bash/002-force-internal-readline.patch
	touch .patched
fi

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--without-bash-malloc \
	bash_cv_wexitstatus_offset=8 \
	bash_cv_getcwd_malloc=yes \
	bash_cv_func_sigsetjmp=present \
	bash_cv_func_snprintf=yes \
	bash_cv_func_vsnprintf=yes \
	bash_cv_printf_a_format=yes \
	bash_cv_job_control_missing=present \
	bash_cv_unusable_rtsigs=no \
	bash_cv_sys_named_pipes=present \
	bash_cv_func_ctype_nonascii=no \
	bash_cv_dup2_broken=no \
	bash_cv_pgrp_pipe=no \
	bash_cv_sys_siglist=no \
	bash_cv_under_sys_siglist=no \
	bash_cv_opendir_not_robust=no \
	bash_cv_ulimit_maxfds=no \
	bash_cv_getenv_redef=yes \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_wcontinued_broken=no \
	bash_cv_func_strcoll_broken=no

	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

####### #####################################################################
# ZSH # #####################################################################
####### #####################################################################
do_ZSH() {
ZSH_VERSION=5.4.2

cd $SRC/zsh

if ! [[ -f .extracted ]]; then
	rm -rf zsh-${ZSH_VERSION}
	tar xzf zsh-${ZSH_VERSION}.tar.gz
	touch .extracted
fi

cd zsh-${ZSH_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

####### #####################################################################
# VIM # #####################################################################
####### #####################################################################
do_VIM() {
VIM_VERSION=8.0

cd $SRC/vim

if ! [[ -f .extracted ]]; then
	rm -rf vim80
	tar xjf vim-${VIM_VERSION}.tar.bz2
	touch .extracted
fi

cd vim80

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--with-tlib=ncurses \
	--enable-multibyte \
	vim_cv_toupper_broken=no \
	vim_cv_terminfo=yes \
	vim_cv_tty_group=world \
	vim_cv_getcwd_broken=no \
	vim_cv_stat_ignores_slash=no \
	vim_cv_memmove_handles_overlap=yes
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE STRIP=$DESTARCH-linux-strip
	touch .installed
fi

if ! [[ -f .installed_config ]]; then
	cp ../.vimrc $DEST
	touch .installed_config
fi

if ! [[ -f $DEST/bin/vi ]]; then
	ln -s vim $DEST/bin/vi
fi
}

######## ####################################################################
# TMUX # ####################################################################
######## ####################################################################
do_TMUX() {
TMUX_VERSION=2.6

cd $SRC/tmux

if ! [[ -f .extracted ]]; then
	rm -rf tmux-${TMUX_VERSION}
	tar xzf tmux-${TMUX_VERSION}.tar.gz
	touch .extracted
fi

cd tmux-${TMUX_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

######### ###################################################################
# UNZIP # ###################################################################
######### ###################################################################
do_UNZIP() {
UNZIP_VERSION=60

cd $SRC/unzip

if ! [[ -f .extracted ]]; then
	rm -rf unzip${UNZIP_VERSION}
	tar xzf unzip${UNZIP_VERSION}.tar.gz
	touch .extracted
fi

cd unzip${UNZIP_VERSION}

if ! [[ -f .patched ]]; then
	patch unix/Makefile < $PATCHES/unzip/unzip.patch
	touch .patched
fi

if ! [[ -f .built ]]; then
	PREFIX=$PREFIX \
	RPATH=$RPATH \
	make -f unix/Makefile  linux_noasm
	touch .built
fi

if ! [[ -f .installed ]]; then
	make prefix=$DEST install
	touch .installed
fi
}

######## ####################################################################
# GZIP # ####################################################################
######## ####################################################################
do_GZIP() {
GZIP_VERSION=1.9

cd $SRC/gzip

if ! [[ -f .extracted ]]; then
	rm -rf gzip-${GZIP_VERSION}
	tar xJf gzip-${GZIP_VERSION}.tar.xz
	touch .extracted
fi

cd gzip-${GZIP_VERSION}

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

########### #################################################################
# BOOST   # #################################################################
########### #################################################################
do_BOOST() {
BOOST_VERSION=1_68_0
BOOST_BLD_DIR="/tmp/build-boost"

cd $SRC/boost

if ! [[ -f .extracted ]]; then
	rm -rf $BOOST_BLD_DIR && mkdir $BOOST_BLD_DIR
	rm -rf boost_${BOOST_VERSION}
	tar xjf boost_${BOOST_VERSION}.tar.bz2
	touch .extracted
fi

cd boost_${BOOST_VERSION}

TOOLPT1="gcc"
TOOLPT2=" "
TOOLPT3="arm-linux-g++"

echo  "using $TOOLPT1 : $TOOLPT2 : $TOOLPT3 ;" > $HOME/user-config.jam
### using gcc : : /<path to custom gcc>/bin/g++ : <linkflags>"-Wl,-rpath -Wl,/<path to custom gcc>/lib64"

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./bootstrap.sh \
		--prefix=$DEST \
		--libdir=$DEST/lib \
		--includedir=$DEST/include \
		--with-libraries=$BOOST_LIBS \
		address-model=32 \
		link=shared \
		runtime-link=shared \
		threading=multi
	touch .configured
fi

## NOTE: b2 == bjam (bjam is old name)
## http://www.boost.org/build/doc/html/bbv2/overview/invocation.html
if ! [[ -f .built ]]; then
	echo; echo "BUILDING"; echo; echo; echo "using $TOOLPT1 : $TOOLPT2 : $TOOLPT3 ;"; echo; echo;
	#####
	PATH=$BOOST_BLD_DIR:$PATH CC="$DESTARCH-linux-gcc" CXX="$DESTARCH-linux-g++" AR="$DESTARCH-linux-ar" \
	LDFLAGS=$LDFLAGS CPPFLAGS=$CPPFLAGS CFLAGS=$CFLAGS CXXFLAGS=$CXXFLAGS && \
	./b2 -a install \
		--no-mpi --no-python --no-samples --no-tests --disable-long-double \
		--toolset=gcc-7.3.0 --build-dir="$BOOST_BLD_DIR" \
		include=static,shared link=static,shared cxxflags=-fPIC \
		-sBZIP2_INCLUDE=$DEST/include -sBZIP2_LIBPATH=$DEST/lib \
		-sZLIB_INCLUDE=$DEST/include -sZLIB_LIBPATH=$DEST/lib \
		-sLZMA_INCLUDE=$DEST/include -sLZMA_LIBPATH=$DEST/lib
	## operations are: "install" or "stage"
	touch .built
fi

rm -f $HOME/user-config.jam
}

################## ##########################################################
# LIBTINS        # ##########################################################
################## ##########################################################

## Tins wont do both at once as-is
## So just do it twice
do_LIBTINS_STEP() {
cd $SRC/libtins

local SHARED_OR_STATIC=1; # shared
case "$1" in
	"static") SHARED_OR_STATIC=0;;
	"shared") SHARED_OR_STATIC=1;;
	*) echo "Invalid arg for do_LIBTINS_STEP. Must be \"shared\" or \"static\"";
	echo; exit 1;
	;;
esac

TINS_LD_FLAGS="";
case "$2" in
	"1") TINS_LD_FLAGS="$LDFLAGS -lssl -lcrypto ";;
	  *) TINS_LD_FLAGS="$LDFLAGS ";
	;;
esac

if ! [[ -f ".extracted-$1" ]]; then
	rm -rf "libtins-${LIBTINS_VERSION}-$1"
	tar xzf libtins-${LIBTINS_VERSION}.tar.gz
	mv libtins-${LIBTINS_VERSION} libtins-${LIBTINS_VERSION}-$1
	touch ".extracted-$1"
fi

cd $SRC/libtins/libtins-${LIBTINS_VERSION}-$1

if ! [[ -f ".configured-$1" ]]; then
	rm -rf build && mkdir build && cd build
	env PATH="$SRC/libtins/libtins-${LIBTINS_VERSION}-$1/bin:$BOOST_BLD_DIR:$PATH" \
	cmake ../ \
		-DCMAKE_INSTALL_PREFIX=$PREFIX \
		-DCMAKE_INCLUDE_PATH=$DEST/include \
		-DCMAKE_LIBRARY_PATH=$DEST/lib \
		-DBOOST_ROOT=$BOOST_BLD_DIR/boost \
		-DBOOST_LIBRARYDIR=$BOOST_BLD_DIR/boost/bin.v2/libs \
		-DCMAKE_C_COMPILER="$DESTARCH-linux-gcc" \
		-DCMAKE_CXX_COMPILER="$DESTARCH-linux-g++" \
		-DCMAKE_C_FLAGS="$CFLAGS" \
		-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
		-DCMAKE_EXE_LINKER_FLAGS="$TINS_LD_FLAGS" \
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
		-DLIBTINS_ENABLE_CXX11=1 \
		-DLIBTINS_BUILD_SHARED=$SHARED_OR_STATIC \
		-DLIBTINS_ENABLE_WPA2=$2 \
		-DLIBTINS_ENABLE_ACK_TRACKER=1 \
		-DCROSS_COMPILING=1
		touch ../.configured-$1
	echo "libtins-$1 configured"
fi

cd $SRC/libtins/libtins-${LIBTINS_VERSION}-$1
if ! [[ -f ".built-$1" ]]; then
	cd build
	make
	touch ".built-$1"
fi

cd $SRC/libtins/libtins-${LIBTINS_VERSION}-$1
if ! [[ -f ".installed-$1" ]]; then
	cd build
	make install DESTDIR=$BASE
	touch ".installed-$1"
fi
}

do_LIBTINS() {
LIBTINS_VERSION=4.0

cd $SRC/libtins

### static/shared, 1/0 for WPA2
do_LIBTINS_STEP "static" "1";
do_LIBTINS_STEP "shared" "1";

}

######### ####################################################################
# MONIT # ####################################################################
######### ####################################################################
do_MONIT() {
MONIT_VERSION=5.25.1

cd $SRC/monit

if ! [[ -f .extracted ]]; then
	rm -rf monit-${MONIT_VERSION}
	tar xJf monit-${MONIT_VERSION}.tar.gz
	touch .extracted
fi

cd monit-${MONIT_VERSION}

if ! [[ -f configure ]]; then
	./bootstrap
fi

if ! [[ -f .configured ]]; then
	LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE
	touch .configured
fi

if ! [[ -f .built ]]; then
	$MAKE
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	touch .installed
fi
}

################## ##########################################################
# RAPIDJSON      # ##########################################################
################## ##########################################################
do_RAPIDJSON() {
RAPIDJSON_VERSION=1.1.0

cd $SRC/rapidjson

if ! [[ -f .extracted ]]; then
	rm -rf rapidjson-${RAPIDJSON_VERSION}
	tar xzf rapidjson-${RAPIDJSON_VERSION}.tar.gz
	touch .extracted
fi

cd rapidjson-${RAPIDJSON_VERSION}

if ! [[ -f .configured ]]; then
	rm -rf build && mkdir build && cd build
	cmake ../ \
		-DCMAKE_INSTALL_PREFIX=$PREFIX \
		-DCMAKE_INCLUDE_PATH=$DEST/include \
		-DCMAKE_LIBRARY_PATH=$DEST/lib \
		-DCMAKE_C_COMPILER="$DESTARCH-linux-gcc" \
		-DCMAKE_CXX_COMPILER="$DESTARCH-linux-g++" \
		-DCMAKE_C_FLAGS="$CFLAGS" \
		-DCMAKE_CXX_FLAGS="$CFLAGS" \
		-DRAPIDJSON_BUILD_DOC=OFF \
		-DRAPIDJSON_BUILD_EXAMPLES=OFF \
		-DRAPIDJSON_BUILD_TESTS=OFF \
		-DCMAKE_CROSSCOMPILING=1
		touch .configured
	echo "rapidjson-${RAPIDJSON_VERSION} configured"
fi

if ! [[ -f .built ]]; then
	$MAKE
	echo "rapidjson-${RAPIDJSON_VERSION} built"
	touch .built
fi

if ! [[ -f .installed ]]; then
	make install DESTDIR=$BASE
	echo "rapidjson-${RAPIDJSON_VERSION} installed"
	touch .installed
fi
}




################## ##########################################################
# END            # ##########################################################
################## ##########################################################

base_main "$BASELIST";
exitres=$?

echo; echo "base.sh install complete"; echo;

exit $exitres;
#### end
