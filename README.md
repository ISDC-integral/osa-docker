# Official INTEGRAL OSA Docker

https://hub.docker.com/repository/docker/integralsw/osa/

[![Docker Pulls](https://img.shields.io/docker/pulls/integralsw/osa.svg)](https://hub.docker.com/repository/docker/integralsw/osa/)

example usage:

```bash
export CURRENT_IC=/isdc/arc/rev_3
export REP_BASE_PROD=/isdc/arc/rev_3/

./osa-docker.sh og_create scw.list IBIS test ./
./osa-docker.sh cd obs/test\; ibis_science_analysis

```

useful single-line command, also disabling automatic image pull:

```bash
OSA_DOCKER_PULL=no \
REP_BASE_PROD=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
CURRENT_IC=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
    bash <(curl https://gitlab.astro.unige.ch/savchenk/osa-docker/raw/master/osa-docker.sh) \
        ibis_science_analysis
```


## Running a mult-line command

The example above uses a single command. More complex operations can be stored in a script and executed a single command.
But sometimes it's useful to run a multi-line command at once. It can be done by escaping the command separators (replacing `;` with `\;`) or 
passing the command as an argument to bash, in single quotes line so:

```
REP_BASE_PROD=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
CURRENT_IC=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
    bash ./osa-docker.sh \
        bash -c '
            cd obs/my_obs;
            export COMMONSCRIPT=1; 
            export COMMONLOGFILE=+\$PWD/ibis_log.txt;
                ibis_science_analysis \
                    ogDOL="og_ibis.fits" startLevel="COR" endLevel="SPE" \
                    SWITCH_disablePICsIT="YES" SWITCH_disableIsgri="NO" \
                    IBIS_nregions_spe="1" IBIS_nbins_spe="27" \
                    IBIS_energy_boundaries_spe="20 200" SCW2_cat_for_extract="isgri_srcl_res.fits[1]"
        '
```

## Please beware of the directory layout!

Please beware that the filesystem as seen by the command in the container is not entirely 