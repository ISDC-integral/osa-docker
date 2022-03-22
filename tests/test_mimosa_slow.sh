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
    endLevel=IMA

echo 1 > mimosa.mosa
find -name isgri_sky_ima.fits >> mimosa.mosa

cat -n mimosa.mosa 

mimosa \
    covrMod="/data/ic/ibis/mod/isgr_covr_mod_0002.fits[1]" \
    corrDol="/data/ic/ibis/mod/isgr_effi_mod_0011.fits[1]" \
    inCat=$(find -name isgri_catalog.fits)

ls -lotr 

fstruct out_mosa_ima.fits

fimgstat out_mosa_ima.fits[4] INDEF INDEF
