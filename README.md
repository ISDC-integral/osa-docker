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


## Running a multi-line command

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

## Singularity container

Singularity container can be run without root advanced privileges, and is usually available on HPC clusters.

You may need to install singularity, e.g. from conda:

```
$ conda install singularity -c conda-forge
```

then, you need to build singularity image:

```
$ ./osa-container.sh build-singularity-image
```

Instead of building the image, you can try to download it (but please beware that we do not maintain the same set of singularity image versions as the docker image versions, although we try to keep the latest version available):

```
$ ./osa-container.sh download-singularity-image
```

## Choosing OSA version

OSA version to use can be selected by setting `OSA_VERSION` variable, like:

```bash
$ export OSA_VERSION=11.2
```

or

```bash
$ export OSA_VERSION=10.2
```

For each new OSA version a new container can be built.
Pre-built docker and singularity containers are provided for some versions, but much larger set of versions can be build from source (using `make build`).

The default setting for `OSA_VERSION` is `current` - in this case, the latest patch version of OSA is used. While major and minor OSA versions (10.2, 11.1, etc) are distributed with accompanying announcements, small bug fixes and patches are introduced farily regularly.
For example, this is full OSA version at the time of writing this: `11.2-2-g667521a3-20220403-190332`. It means it is two patches after `11.2`, as defined on April 4 2022. 

It is advisable to use the current OSA version when possible, but if in doubt the last minor release can be used to check (`11.2` in the example above).


## More on directory locations

In the convention of INTEGRAL OSA analysis `REP_BASE_PROD` contains `scw`, `ic`, `idx`, `aux`, `cat` directories. In ordinary analysis, some of them can be symlinks.
When mounted into the container, symlinks do not work the same way.

So when specifying `REP_BASE_PROD` variable, it is important that it contains actual data, not symlinks to it.
Sometimes actual locations of `ic` and `idx` may be in a different place: since they are primarily associated with software and not with data. In this case, it is possible to specify `CURRENT_IC` variable to point to the directory with actual location of `ic` and `idx`.

## Please beware of the directory layout!

Beware that the filesystem as seen by the command in the container is not the same as in the host system. 
The current directory is seen as `/home/integral`. Please see the helpful messsage.

You can explore what is visible to the commands in docker like so:

```
./osa-container.sh docker ls /home/integral
```

## Using singularity instead of docker

You can use a singularity image which you can build yourself from docker image with this command:

```
./osa-container.sh build-singularity
```

Then, this command:

```
./osa-container.sh docker ls /home/integral
```

will produce the same result as this one:

```
./osa-container.sh singularity ls /home/integral
```

An advantage of singularity is that it requires less rights on the host, and hence is usually available on HPC clusters (unlike docker).