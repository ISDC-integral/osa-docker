# Official INTEGRAL OSA Docker

https://hub.docker.com/repository/docker/integralsw/osa/

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