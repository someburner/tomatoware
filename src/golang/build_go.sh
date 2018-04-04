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

cd ./go1.4/src

if ! [[ -f .bootstrapped ]]; then
	rm -f .bootstrapped
	#env GOOS=linux GOARCH=arm GOARM=5 GO_TEST_TIMEOUT_SCALE=10 taskset 1 ./make.bash
	./make.bash
	! [[ $? -eq 0 ]] && exit 1;

	echo "successfuly built bootstrapped go1.4"
	touch .bootstrapped
fi

cd $PREFIX/bin/go
wget https://redirector.gvt1.com/edgedl/go/go1.10.src.tar.gz
tar zxvf go1.10.src.tar.gz -C $PREFIX/bin
cd $PREFIX/bin/go/src

wget -O $PREFIX/ssl/certs/ca-certificates.crt https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt

sed -i 's,\/etc\/ssl\/certs\/ca-certificates.crt,'"$PREFIX"'\/ssl\/certs\/ca-certificates.crt,g' ./crypto/x509/root_linux.go

GOROOT_BOOTSTRAP=$PREFIX/bin/go/bootstrap/go1.4 ./make.bash
echo "Go has been installed."
