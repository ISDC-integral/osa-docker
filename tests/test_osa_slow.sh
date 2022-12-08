#!/bin/bash

# set -ex
set -ex

source /init.sh

echo $REP_BASE_PROD
echo $CURRENT_IC


rm -fv aux cat ic idx scw
ln -s /data/* .

ls -l scw

ls $PWD/scw/0665/0665002*/swg.fits* | head -1 > scw.idx


cat scw.idx

export COMMONLOGFILE=+$PWD/commonlog.txt
export COMMONSCRIPT=1

plist og_create

og_create \
    idxSwg=scw.idx \
    ogid=test-ogid \
    instrument=IBIS \
    baseDir=$PWD

cd obs/*

plist dal_list
dal_list fulldols=yes dol=$PWD/og_ibis.fits

echo $PFILES

# strace -e open 
ibis_science_analysis \
    endLevel=LCR
