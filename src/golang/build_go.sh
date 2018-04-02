#!/bin/bash

PREFIX=/mmc

set -e
set -x

if ! [[ -d $PREFIX/bin/go ]]; then
	mkdir -p $PREFIX/bin/go/bootstrap && cd $PREFIX/bin/go/bootstrap
	wget https://storage.googleapis.com/golang/go1.4.3.src.tar.gz
	tar zxvf go1.4.3.src.tar.gz
	mv go go1.4
else
	cd $PREFIX/bin/go/bootstrap
fi;
echo;
cd ./go1.4/src
echo;

#-O2 -pipe -march=armv7-a -mtune=cortex-a9
export CFLAGS="-O2 -g -pipe -march=armv7-a -mtune=cortex-a9"
export CC="arm-buildroot-linux-uclibcgnueabi-gcc-7.2.0"
export GOGCCFLAGS="$CFLAGS" && \
export GO_GCFLAGS="$CFLAGS" && \
export CGO_ENABLED="1" && \
export PKG_CONFIG="/mmc/bin/pkg-config" && \
export GOBUILDTIMELOGFILE="/opt/tmp/golog.log" && bash -x ./make.bash -v
! [[ $? -eq 0 ]] && exit 1;
echo;


cd $PREFIX/bin/go
wget https://redirector.gvt1.com/edgedl/go/go1.10.src.tar.gz
tar zxvf go1.10.src.tar.gz -C $PREFIX/bin
cd $PREFIX/bin/go/src

wget -O $PREFIX/ssl/certs/ca-certificates.crt https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt

sed -i 's,\/etc\/ssl\/certs\/ca-certificates.crt,'"$PREFIX"'\/ssl\/certs\/ca-certificates.crt,g' ./crypto/x509/root_linux.go

GOROOT_BOOTSTRAP=$PREFIX/bin/go/bootstrap/go1.4 ./make.bash
echo "Go has been installed."
