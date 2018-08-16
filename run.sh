mkdir -pv /tmp/osa-home-$$
mkdir -pv /tmp/osa-home-$$-pfiles

docker run \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /tmp/osa-home-$$-pfiles:/pfiles \
    -v /tmp/osa-home-$$:/home/integral \
    --rm -it --user $(id -u) \
        integralsw/osa:11.0 bash -c 'export HOME=/home/integral; source init.sh; ibis_science_analysis'
