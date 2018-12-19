#!/bin/sh

RELEASE="12.0-STABLE"

git submodule init
git submodule update

fetch http://ftp.freebsd.org/pub/FreeBSD/snapshots/amd64/${RELEASE}/kernel.txz
fetch http://ftp.freebsd.org/pub/FreeBSD/snapshots/amd64/${RELEASE}/base.txz
fetch http://ftp.freebsd.org/pub/FreeBSD/snapshots/amd64/${RELEASE}/boot.txz

cp conf/* mfsbsd/conf/

cd mfsbsd
make MFSROOT_MAXSIZE=1G BASE=..
