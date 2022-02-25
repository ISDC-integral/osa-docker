#!/bin/bash

set -e

source /init.sh

echo $REP_BASE_PROD
echo $CURRENT_IC


ln -s /data/* .

ls $PWD/scw/*/*/swg.fits > scw.idx

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

strace -e open ibis_science_analysis \
    endLevel=LCR
