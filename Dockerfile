FROM centos:7

RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install gcc gcc-c++ gcc-gfortran \
                   git curl make zlib-devel bzip2 bzip2-devel \
                   readline-devel sqlite sqlite-devel openssl \
                   openssl-devel patch libjpeg libpng12 libX11 \
                   which libXpm libXext curlftpfs wget libgfortran file \
                   ruby-devel fpm rpm-build \
                   ncurses-devel \
                   libXt-devel libX11-devel libXpm-devel libXft-devel libXext-devel \
                   cmake openssl-devel pcre-devel mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel \
                   mysql-devel fftw-devel cfitsio-devel graphviz-devel avahi-compat-libdns_sd-devel libldap-dev python-devel libxml2-devel gsl-static \
                   compat-gcc-44 compat-gcc-44-c++ compat-gcc-44-c++.gfortran \
                   perl-ExtUtils-MakeMaker \
                   net-tools strace sshfs sudo iptables

RUN ln -s /usr/lib64/libpcre.so.1 /usr/lib64/libpcre.so.0
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && yum -y install git-lfs
RUN cp -fv /usr/bin/gfortran /usr/bin/g95

ADD init.sh /init.sh
ADD init.d /init.d

# heasoft

ARG HEASOFT_PLATFORM=CentOS_7.5.1804_x86_64

RUN cd /opt && \
    wget -q https://www.isdc.unige.ch/~savchenk/gitlab-ci/savchenk/osa-build-heasoft-binary-tarball/${HEASOFT_PLATFORM}/heasoft-${HEASOFT_PLATFORM}.tar.gz && \
    tar xzf heasoft-*.tar.gz && \
    pwd && \
    rm -fv heasoft-*.tar.gz && \
    echo $'export HEADAS=/opt/heasoft/x86_64-pc-linux-gnu-libc2.17/\n\
          source $HEADAS/headas-init.sh' > /init.d/10-heasoft.sh

RUN cat /init.d/10-heasoft.sh


# OSA 

ARG OSA_VERSION=11.1-16-g88c002b7-20210507-170349
ARG OSA_PLATFORM=CentOS_7.8.2003_x86_64

RUN cd /opt/ && \
    if [ ${OSA_VERSION} == "10.2" ]; then \
        wget -q https://www.isdc.unige.ch/integral/download/osa/sw/10.2/osa10.2-bin-linux64.tar.gz && \
        tar xzf osa10.2-bin-linux64.tar.gz && \
        rm -fv osa10.2-bin-linux64.tar.gz && \
        mv osa10.2 osa; \
    else \
        wget -q https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-binary-tarball/${OSA_PLATFORM}/${OSA_VERSION}/build-latest/osa-${OSA_VERSION}-${OSA_PLATFORM}.tar.gz && \
        tar xzf osa-${OSA_VERSION}-*.tar.gz && \
        rm -fv osa-${OSA_VERSION}-*.tar.gz && \
        mv osa11 osa; \
    fi && \
    echo 'export ISDC_REF_CAT=/data/cat/hec/gnrl_refr_cat_0043.fits #TODO: use a variable, substitute from build time\n\
          export ISDC_OMC_CAT=/data/cat/omc/omc_refr_cat_0005.fits\n\
          export REP_BASE_PROD=/data\n\
          export ISDC_ENV=/opt/osa\n\
          source $ISDC_ENV/bin/isdc_init_env.sh' > /init.d/20-osa.sh



ARG isdc_ref_cat_version=43.0

RUN wget -q https://www.isdc.unige.ch/integral/download/osa/cat/osa_cat-${isdc_ref_cat_version}.tar.gz && \
    tar xvzf osa_cat-${isdc_ref_cat_version}.tar.gz && \
    mkdir -pv /data/ && \
    mv osa_cat-${isdc_ref_cat_version}/cat /data/ && \
    rm -rf osa_cat-${isdc_ref_cat_version}

RUN wget -q http://ds9.si.edu/download/centos7/ds9.centos7.8.2.1.tar.gz && \
    tar xvfz ds9.centos7.8.2.1.tar.gz && \
    chmod a+x ds9 && \
    mv ds9 /usr/local/bin && \
    rm -f ds9.centos7.8.2.1.tar.gz

ADD tests /tests
