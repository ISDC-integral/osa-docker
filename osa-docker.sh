#!/bin/bash

set -xe

COMMAND=$@

echo "REP_BASE_PROD: ${REP_BASE_PROD:?please set this variable to the current data location}"
echo "CURRENT_IC: ${CURRENT_IC:?please set this variable to the current IC location}"

echo "using WORKDIR: ${WORKDIR:=$PWD}"

mkdir -pv $WORKDIR
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
        integralsw/osa:11.0 bash -c "

cat init.sh
. init.sh

cd \$HOME

echo -e '\\e[31mrunning\\e[37m $COMMAND\\e[0m'

$COMMAND
"
