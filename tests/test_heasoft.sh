#!/bin/bash

set -e

source /init.sh

which fstruct
plist fstruct 


wget -q https://fits.gsfc.nasa.gov/samples/WFPC2u5780205r_c0fx.fits -O test.fits

fstruct test.fits
