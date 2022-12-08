# Official INTEGRAL OSA Docker

https://hub.docker.com/repository/docker/integralsw/osa/

[![Docker Pulls](https://img.shields.io/docker/pulls/integralsw/osa.svg)](https://hub.docker.com/repository/docker/integralsw/osa/)

example usage:

```bash
export CURRENT_IC=/isdc/arc/rev_3
export REP_BASE_PROD=/isdc/arc/rev_3/

./osa-container.sh docker og_create scw.list IBIS test ./
./osa-container.sh docker cd obs/test\; ibis_science_analysis

```

useful single-line command, also disabling automatic image pull:

```bash
OSA_DOCKER_PULL=no \
REP_BASE_PROD=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
CURRENT_IC=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
    bash <(curl https://gitlab.astro.unige.ch/savchenk/osa-docker/raw/master/osa-container.sh) \
        docker \
        ibis_science_analysis
```


## Running a mult-line command

The example above uses a single command. More complex operations can be stored in a script and executed a single command.
But sometimes it's useful to run a multi-line command at once. It can be done by escaping the command separators (replacing `;` with `\;`) or 
passing the command as an argument to bash, in single quotes line so.

Consider this (WRONG!) example:

```
REP_BASE_PROD=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
CURRENT_IC=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
    bash ./osa-docker.sh pwd; pwd
```

Note that the first `pwd` will be run inside the docker, while the second `pwd` is a separate command, not passed to the `osa-docker.sh` script and run in the host system.

Instead, this will run both `pwd` in the container

```
$ REP_BASE_PROD=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
CURRENT_IC=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
    bash ./osa-docker.sh pwd\; pwd
```

This will also work well:

```
$ REP_BASE_PROD=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
CURRENT_IC=/mnt/sshfs/isdc/isdc/arc/rev_3/ \
    bash  ./osa-docker.sh bash -c 'pwd; pwd'
```


## Please beware of the directory layout!

Please beware that the filesystem as seen by the command in the container is not the same as in the host system. 
The current directory is seen as `/home/integral`. Please see the helpful messsage.

You can explore what is visible to the commands in docker like so:

```
./osa-container.sh docker ls /home/integral
./osa-container.sh singularity ls /home/integral
```