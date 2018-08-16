export HEADAS=/heasoft/x86_64-unknown-linux-gnu-libc2.17/
source $HEADAS/headas-init.sh

rm -rf $HOME/pfiles
export ISDC_ENV=/osa
source $ISDC_ENV/bin/isdc_init_env.sh

export CURRENT_IC=/data/ic_tree_current
export REP_BASE_PROD=/data/rep_base_prod

export F90=gfortran #f95
export F95=gfortran #f95
export F77=gfortran #f95
export CC="gcc44" # -Df2cFortran"
export CXX="g++44" # -Df2cFortran"
source $HOME/root/bin/thisroot.sh


source heasoft_init.sh

sh setup_curlftpfs.sh
mkdir -p /data/rep_base_prod/scw

echo "mounting.."
#curlftpfs -o nonempty ftp://isdcarc.unige.ch/arc/rev_3/aux/ /data/rep_base_prod/aux
#curlftpfs -o nonempty ftp://isdcarc.unige.ch/arc/rev_3/scw/ /data/rep_base_prod/scw


#ls /data/rep_base_prod/scw/0665
#ls -l /data/ic_tree_current/ic/ibis/mod/isgr_mask_mod_0003.fits

#ls -l /data/rep_base_prod/scw/0665/066500230010.001


