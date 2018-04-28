#!/usr/bin/env bash

### INSTALL

backup() {
mv /opt/etc/profile /opt/etc/profile.mmc
mv /opt/etc/profile.opt /opt/etc/profile

cd /mmc
tar cjf home-bk.tar.bz2 home
mv home-bk.tar.bz2 /mnt/
}

cd /opt/tmp/mmc_install

rm -rf /mmc/*
rm -f /mmc/.vimrc /mmc/.autorun

## tbz
tar xf arm-soft-mmc.tgz -C /mmc
## bz2
tar xjf arm-soft-mmc.tar.bz2

## restore home
mv /mnt/mmc_home /mmc/home
cp -f /opt/etc/saved_profiles/profile.mmc /mmc/etc/profile

## set mmc profile
mv /opt/etc/profile /opt/etc/profile.opt
mv /opt/etc/profile.mmc /opt/etc/profile


# cd /mmc
# cp xjf home-save.tar.bz2 .
# tar xjvf home-save.tar.bz2

# --delay-directory-restore
# --recursive-unlink
# --unlink-first
#
