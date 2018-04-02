#!/bin/bash

rm -f /usr/bin/perl*;
apt-get remove perl -y;
apt-get purge perl-base tex-common* -y;
sleep 5;
apt-get install perl perl-base git build-essential --reinstall -y;
sleep 5;
apt-get --fix-broken install -y;
sleep 5;
apt-get install perl perl-base git build-essential --reinstall -y;
sleep 5;
