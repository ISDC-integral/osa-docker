FROM centos

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

ARG uid
RUN groupadd -r integral -g $uid && useradd -u $uid -r -g integral integral && \
    mkdir /home/integral /data && \
    chown -R integral:integral /home/integral /data

USER integral

## pyenv

WORKDIR /home/integral

RUN git clone git://github.com/yyuu/pyenv.git .pyenv

ENV HOME  /home/integral
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN export PYTHON_CONFIGURE_OPTS="--enable-shared" && pyenv install 2.7.12
RUN pyenv global 2.7.12
RUN pyenv rehash

RUN pip install pip --upgrade
RUN pip install future
RUN pip install numpy scipy astropy matplotlib

## install heasoft

ADD heasoft_init.sh .

# root

RUN cd / && \
    wget https://root.cern.ch/download/root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz && \
    tar xvzf root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz && \
    rm -f root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz 

# heasoft

RUN cd / && \
    wget https://www.isdc.unige.ch/~savchenk/gitlab-ci/savchenk/osa-build-heasoft-binary-tarball/CentOS_7.5.1804_x86_64/heasoft-CentOS_7.5.1804_x86_64.tar.gz && \
    tar xvzf heasoft-CentOS_7.5.1804_x86_64.tar.gz && \
    rm -fv  heasoft-CentOS_7.5.1804_x86_64.tar.gz

# OSA

RUN cd / && \
    wget https://www.isdc.unige.ch/~savchenk/gitlab-ci/savchenk/osa-build-binary-tarball/CentOS_7.5.1804_x86_64/osa-CentOS_7.5.1804_x86_64.tar.gz && \
    tar xvzf osa-CentOS_7.5.1804_x86_64.tar.gz && \
    rm -fv  osa-CentOS_7.5.1804_x86_64.tar.gz

# prep OSA
# prep data

RUN mkdir -pv /data/rep_base_prod/aux /data/ic_tree_current/ic /data/ic_tree_current/idx /data/resources /data/rep_base_prod/cat /data/rep_base_prod/ic /data/rep_base_prod/idx && \
    chown -R integral:integral /data/rep_base_prod/aux /data/ic_tree_current/ic /data/ic_tree_current/idx /data/resources /data/rep_base_prod/cat /data/rep_base_prod/ic /data/rep_base_prod/idx

RUN mkdir -pv /host_var; chown integral:integral /host_var &&  \
    mkdir -pv /data/rep_base_prod; chown integral:integral /data/rep_base_prod 
USER integral

# pfiles

RUN rm -rf /home/integral/pfiles

# jupyter

RUN mkdir -p /home/integral/.jupyter/
ADD jupyter_notebook_config.json /home/integral/.jupyter/jupyter_notebook_config.json
EXPOSE 8888

ADD init.sh

