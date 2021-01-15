FROM centos:7
MAINTAINER AIZAWA Hina <hina@bouhime.com>

ADD docker/nginx/nginx.repo /etc/yum.repos.d/
ADD docker/rpm-gpg/ /etc/pki/rpm-gpg/
ADD docker/jp3cki/jp3cki.repo /etc/yum.repos.d/

RUN rpm --import \
    /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
    /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo \
    /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 \
    /etc/pki/rpm-gpg/RPM-GPG-KEY-JP3CKI \
    /etc/pki/rpm-gpg/RPM-GPG-KEY-remi \
        && \
    yum update -y && \
    yum install -y \
        ImageMagick \
        centos-release-scl-rh \
        curl \
        epel-release \
        nginx \
        patch \
        pngcrush \
        scl-utils \
        sqlite \
        tar \
        unzip \
        wget \
        http://rpms.famillecollet.com/enterprise/7/safe/x86_64/remi-release-7.2-1.el7.remi.noarch.rpm \
            && \
    yum-config-manager --enable jp3cki && \
    yum install -y \
        brotli \
        git19-git \
        nodejs010-npm \
        php70-php-cli \
        php70-php-fpm \
        php70-php-intl \
        php70-php-json \
        php70-php-mbstring \
        php70-php-mcrypt \
        php70-php-opcache \
        php70-php-pdo \
        php70-php-pecl-zip \
        php70-php-xml \
        supervisor \
        zopfli \
            && \
    yum clean all && \
    useradd festink && \
    chmod 701 /home/festink

ADD docker/env/scl-env.sh /etc/profile.d/
ADD docker/supervisor/* /etc/supervisord.d/
ADD . /home/festink/fest.ink
RUN chown -R festink:festink /home/festink/fest.ink

USER festink
RUN cd ~festink/fest.ink && bash -c 'source /etc/profile.d/scl-env.sh && make clean && rm -rf runtime/* && make'

USER root
ADD docker/php/php-config.diff /tmp/
RUN patch -p1 -d /etc/opt/remi/php70 < /tmp/php-config.diff && rm /tmp/php-config.diff

ADD docker/nginx/default.conf /etc/nginx/conf.d/

CMD /usr/bin/supervisord
EXPOSE 80
