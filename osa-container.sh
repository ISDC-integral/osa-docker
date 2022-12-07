#!/bin/bash

set -xe

runmode=run-${1:?please specify mode in the first argument: docker or singularity}
shift
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
    if [ -L $directory ] ; then 
	    echo -e "\033[033mWARNING: directory \"$directory\" is a symlink, which may break since inside the container the filesystem layout is different\033[0m"; 
    fi

    if [ ! -d $directory ] ; then 
	    echo -e "\033[31mERROR: directory \"$directory\" should exist\033[0m"
	    exit 1
    fi
done

[ -s /tmp/.X11-unix ] || { echo "no /tmp/.X11-unix? no X? not allowed!"; }

mkdir -pv $WORKDIR/pfiles


function run-docker() {
    bashcmd=$@

    docker run \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $WORKDIR:/home/integral \
        -v $REP_BASE_PROD/scw:/data/scw:ro \
        -v $REP_BASE_PROD/aux:/data/aux:ro \
        -v $CURRENT_IC/ic:/data/ic:ro \
        -v $CURRENT_IC/idx:/data/idx:ro \
        --rm -it  --user $(id -u) --entrypoint='' \
            ${OSA_DOCKER_IMAGE} $bashcmd
}


function run-singularity() {
    bashcmd=${1:?}

    echo "WIP!"
}

                
$runmode bash -c "

    export HOME_OVERRRIDE=/home/integral

    . init.sh

    ## check from inside now

    for directory in /data/scw /data/aux /data/ic /data/idx; do
        if [ -L \$directory ] ; then 
            echo -e \"\\033[033mWARNING: inside the container, directory \\\"\$directory\\\" exits, but is a symlink, which may break since inside the container the filesystem layout is different\\033[0m\"
        fi
        ls -ldA \$directory
        if [ ! -d \$directory ] ; then  
                echo -e \"\\033[31mERROR: inside the container, directory \\\"\$directory\\\" should exist\\033[0m\"
                exit 1;
        fi
    done

    ## done

    cd \$HOME

    echo -e '\nplease beware that \\e[34m$WORKDIR\\e[0m is visible to commands in docker as \\e[34m/home/integral\\e[37m\\e[0m\n'

    echo -e '\\e[31mrunning\\e[37m $COMMAND\\e[0m'

    $COMMAND

    "

