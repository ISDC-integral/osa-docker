#!/bin/bash

#set -xe

COMMAND=$@


echo "OSA_VERSION == ${OSA_VERSION:=latest}"
echo "OSA_DOCKER_IMAGE == ${OSA_DOCKER_IMAGE:=integralsw/osa:${OSA_VERSION}}"
echo "OSA_DOCKER_PULL == \"${OSA_DOCKER_PULL:=yes}\""

[ "x$OSA_DOCKER_PULL" == "xyes" ] && {
    echo "will update image (set OSA_DOCKER_PULL to anything but \"yes\" to stop this)"
    docker pull $OSA_DOCKER_IMAGE
}

echo "."
echo "."
echo "REP_BASE_PROD: ${REP_BASE_PROD:?please set this variable to the current data location}"
echo "CURRENT_IC: ${CURRENT_IC:=$REP_BASE_PROD}"
echo "using WORKDIR: ${WORKDIR:=$PWD}"


for directory in "$REP_BASE_PROD/scw" "$REP_BASE_PROD/aux" "$CURRENT_IC/ic" "$CURRENT_IC/idx" "$WORKDIR"; do
    [ -d $directory ] || { echo "directory \"$directory\" should exist"; exit 1; }
done

[ -s /tmp/.X11-unix ] || { echo "no /tmp/.X11-unix? no X? not allowed!"; }

mkdir -pv $WORKDIR/pfiles

docker run \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $WORKDIR:/home/integral \
    -v $REP_BASE_PROD/scw:/data/scw:ro \
    -v $REP_BASE_PROD/aux:/data/aux:ro \
    -v $CURRENT_IC/ic:/data/ic:ro \
    -v $CURRENT_IC/idx:/data/idx:ro \
    --rm -it  --user $(id -u) \
        ${OSA_DOCKER_IMAGE} bash -c "

. init.sh

cd /home/integral

echo -e '\\e[31mrunning\\e[37m $COMMAND\\e[0m'

$COMMAND
"
