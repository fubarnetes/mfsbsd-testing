#!/bin/sh

ARCH=amd64
FBSD_RELEASE="12.0-STABLE"

git submodule init
git submodule update

fetch -m http://ftp.freebsd.org/pub/FreeBSD/snapshots/${ARCH}/${FBSD_RELEASE}/kernel.txz
fetch -m http://ftp.freebsd.org/pub/FreeBSD/snapshots/${ARCH}/${FBSD_RELEASE}/base.txz

cp conf/* mfsbsd/conf/

cd mfsbsd
make iso MFSROOT_MAXSIZE=1G BASE=..

[ -z $GITHUB_TOKEN ] && ( echo "GITHUB_TOKEN not set. Exiting." && exit 1 )
[ -z $TAG ] && ( echo "TAG not set. Exiting." && exit 1 )

curl \
	-H "Authorization: token $GITHUB_TOKEN" \
	-H "Content-Type: $(file -b --mime-type mfsbsd-${FBSD_RELEASE}-${ARCH}.iso)" \
	--data-binary @mfsbsd-${FBSD_RELEASE}-${ARCH}.iso \
	"https://uploads.github.com/repos/fubarnetes/mfsbsd-testing/releases/${TAG}/assets?name=mfsbsd-${FBSD_RELEASE}-${ARCH}.iso"
