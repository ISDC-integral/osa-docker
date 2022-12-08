#!/bin/bash

if [ "$DEBUG" == "yes" ]; then
    set -xe
fi

runmode=run-${1:?please specify mode in the first argument: docker or singularity}
shift
COMMAND=$@


echo "OSA_VERSION == ${OSA_VERSION:=discover}"

if [ $OSA_VERSION == "discover" ]; then
    OSA_VERSION=$(curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/cross-platform/latest/latest/osa-version-ref.txt)
    echo "discovered OSA_VERSION == ${OSA_VERSION:=discover}"
fi

echo "OSA_DOCKER_IMAGE == ${OSA_DOCKER_IMAGE:=integralsw/osa:${OSA_VERSION}}"
echo "OSA_SINGULARITY_IMAGE == ${OSA_SINGULARITY_IMAGE:=integralsw-osa-${OSA_VERSION}.sif}"
echo "OSA_DOCKER_PULL == \"${OSA_DOCKER_PULL:=yes}\""

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

function maybe_pull() {
    [ "x$OSA_DOCKER_PULL" == "xyes" ] && {
        echo "will update image (set OSA_DOCKER_PULL to anything but \"yes\" to stop this)"
        docker pull $OSA_DOCKER_IMAGE
    }
}

function mount_env_args() {
    mount_flag=${1:?}
    
    echo --env DISPLAY=$DISPLAY \
         $mount_flag /tmp/.X11-unix:/tmp/.X11-unix \
         $mount_flag $WORKDIR:/home/integral \
         $mount_flag $REP_BASE_PROD/scw:/data/scw:ro \
         $mount_flag $REP_BASE_PROD/aux:/data/aux:ro \
         $mount_flag $CURRENT_IC/ic:/data/ic:ro \
         $mount_flag $CURRENT_IC/idx:/data/idx:ro
}


function run-docker() {
    bashcmd="$@"

    maybe_pull

    docker run \
        $( mount_env_args -v ) \
        --rm -it  --user $(id -u) --entrypoint='' \
            ${OSA_DOCKER_IMAGE} bash -c "$bashcmd"
}


function run-singularity() {
    bashcmd="$@"

    singularity exec \
        --no-home \
        $( mount_env_args -B ) \
            ${OSA_SINGULARITY_IMAGE} bash -c "$bashcmd"
}


function run-build-singularity() {
    maybe_pull

    singularity build $OSA_SINGULARITY_IMAGE docker-daemon://$OSA_DOCKER_IMAGE
}

                
$runmode "
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

