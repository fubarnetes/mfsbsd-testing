#!/bin/sh

ARCH=amd64
FBSD_RELEASES="11.2-STABLE 12.0-STABLE"
OWNER=fubarnetes
REPO=mfsbsd-testing

git submodule init
git submodule update

cp conf/* mfsbsd/conf/
cat keys/*.pub >> mfsbsd/conf/authorized_keys

if [ -z $GITHUB_TOKEN ]; then
        echo "GITHUB_TOKEN not set. Exiting."
        exit 1
fi

if [ -z $TAG ]; then
        echo "TAG not set. Exiting."
        exit 1
fi


echo downloading distfiles...
for FBSD_RELEASE in ${FBSD_RELEASES}; do
        mkdir -p ${FBSD_RELEASE}
        curl --progress-bar -C - \
                -o ${FBSD_RELEASE}/kernel.txz \
                http://ftp.freebsd.org/pub/FreeBSD/snapshots/${ARCH}/${FBSD_RELEASE}/kernel.txz
        curl --progress-bar -C - \
                -o ${FBSD_RELEASE}/base.txz \
                http://ftp.freebsd.org/pub/FreeBSD/snapshots/${ARCH}/${FBSD_RELEASE}/base.txz
done

for FBSD_RELEASE in ${FBSD_RELEASES}; do
        rm -rf mfsbsd/work
        make -C mfsbsd iso \
                RELEASE=${FBSD_RELEASE} \
                MFSROOT_MAXSIZE=4g \
                MFSROOT_FREE_BLOCKS="90%" \
                MFSROOT_FREE_INODES="90%" \
                ROOTHACK=1 \
                PRUNELIST=../prunelist \
                BASE=../${FBSD_RELEASE}
done

AUTHHDR="Authorization: token $GITHUB_TOKEN"
# FIXME: check the auth hdr

RELEASE_ID=$(curl -s -H "${AUTHHDR}" https://api.github.com/repos/${OWNER}/${REPO}/releases | jq -r '.[]|select(.tag_name=="'${TAG}'")|.id')
UPLOAD_URL=$(curl -s -H "${AUTHHDR}" https://api.github.com/repos/${OWNER}/${REPO}/releases/${RELEASE_ID} | jq -r '.upload_url' | cut -d'{' -f1 )

echo "uploading images..."
for FBSD_RELEASE in ${FBSD_RELEASES}; do
        ISOFILE=mfsbsd-${FBSD_RELEASE}-${ARCH}.iso
        UPLOAD=$(curl \
                --progress-bar \
                -H "${AUTHHDR}" \
                -H "Content-Type: $(file -b --mime-type mfsbsd/${ISOFILE})" \
                -H "Accept: application/vnd.github.manifold-preview" \
                --data-binary @mfsbsd/${ISOFILE} \
                "${UPLOAD_URL}?name=${ISOFILE}")
done
