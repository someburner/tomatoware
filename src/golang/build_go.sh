#!/bin/bash

PREFIX=/mmc
_GOVERS="1.10.1"

set -e
set -x

echo "Get bootstrapper.."
if ! [[ -d $PREFIX/bin/go ]]; then
	mkdir -p $PREFIX/bin/go/bootstrap && cd $PREFIX/bin/go/bootstrap
	wget https://storage.googleapis.com/golang/go1.4.3.src.tar.gz
	tar zxvf go1.4.3.src.tar.gz
	mv go go1.4
else
	cd $PREFIX/bin/go/bootstrap
fi;

echo "Compile bootstrapper.."
cd ./go1.4/src

if ! [[ -f .bootstrapped ]]; then
	#env GOOS=linux GOARCH=arm GOARM=5 GO_TEST_TIMEOUT_SCALE=10 taskset 1 ./make.bash
	./make.bash
	! [[ $? -eq 0 ]] && exit 1;
	echo "successfuly built bootstrapper (go1.4)"
	touch .bootstrapped
fi

if ! [[ -f .built$_GOVERS ]]; then
	echo "Building go$_GOVERS"
	cd $PREFIX/bin/go

	wget https://redirector.gvt1.com/edgedl/go/go$_GOVERS.src.tar.gz
	tar zxvf go$_GOVERS.src.tar.gz -C $PREFIX/bin
	cd $PREFIX/bin/go/src

	if ! [[ -f .dlcerts ]]; then
		echo "Downloading ca-bundle.crt"
		wget -O $PREFIX/ssl/certs/ca-certificates.crt https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt
		! [[ $? -eq 0 ]] && exit 1;
		echo "Got cert bundle ok."
		touch .dlcerts
	fi

	if ! [[ -f .patch_crt ]]; then
		echo "Patching crypto/x509/root_linux.go with ca-bundle.crt location"
		sed -i 's,\/etc\/ssl\/certs\/ca-certificates.crt,'"$PREFIX"'\/ssl\/certs\/ca-certificates.crt,g' ./crypto/x509/root_linux.go
		! [[ $? -eq 0 ]] && exit 1;
		echo "Patched root_linux.go"
		touch .patch_crt
	fi


	GOROOT_BOOTSTRAP=$PREFIX/bin/go/bootstrap/go1.4 ./make.bash
	! [[ $? -eq 0 ]] && exit 1;
	touch .built$_GOVERS
	echo "successfuly built go compiler v$_GOVERS"

	echo;
	echo "Go compiler returned no errors. Congrats."
	echo "Go v$_GOVERS has been installed."
	echo;
fi

if ! [[ -d $PREFIX/go ]]; then
	mkdir -p $PREFIX/go;
	echo "Created go work dir: $PREFIX/go";
fi

echo "Make sure $PREFIX/go is in your PATH."
echo "To test, go get <something> and check that it populates that directory.";
