FROM alpine:3.2

MAINTAINER Jacob Blain Christen <mailto:dweomer5@gmail.com, https://github.com/dweomer, https://twitter.com/dweomer>

ENV OPENLDAP_VERSION=2.4.40

COPY *.template /srv/openldap/
COPY openldap.sh /srv/

VOLUME ["/etc/openldap/slapd.d", "/var/lib/openldap"]

RUN set -x \
 && chmod -v +x /srv/openldap.sh \
 && mkdir -vp \
        /etc/openldap/sasl2 \
        /srv/openldap.d \
        /tmp/openldap \
 && export BUILD_DEPS=" \
        autoconf \
        automake \
        curl \
        cyrus-sasl-dev \
        db-dev \
        g++ \
        gcc \
        groff \
        gzip \
        libtool \
        make \
        mosquitto-dev \
        openldap-back-bdb \
        openldap-back-ldap \
        openldap-back-meta \
        openldap-back-monitor \
        openldap-back-sql \
        openssl-dev \
        tar \
        unixodbc-dev \
        util-linux-dev \
    " \
 && apk add --update \
        gettext \
        libintl \
        openldap \
        openldap-back-hdb \
        openldap-clients \
        openldap-mqtt \
        unixodbc \
        ${BUILD_DEPS} \
# Grab envsubst from gettext
 && cp -v /usr/bin/envsubst /usr/local/bin/ \
# Install OpenLDAP from source
 && curl -fL ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSION}.tgz -o /tmp/openldap.tgz \
 && curl -fL http://git.alpinelinux.org/cgit/aports/plain/main/openldap/0001-dbd-enabled-by-default.patch?h=3.2-stable -o /tmp/0001-dbd-enabled-by-default.patch \
 && curl -fL http://git.alpinelinux.org/cgit/aports/plain/main/openldap/CVE-2015-1545.patch?h=3.2-stable -o /tmp/CVE-2015-1545.patch \
 && curl -fL http://git.alpinelinux.org/cgit/aports/plain/main/openldap/CVE-2015-1546.patch?h=3.2-stable -o /tmp/CVE-2015-1546.patch \
 && curl -fL http://git.alpinelinux.org/cgit/aports/plain/main/openldap/CVE-2015-6908.patch?h=3.2-stable -o /tmp/CVE-2015-6908.patch \
 && curl -fL http://git.alpinelinux.org/cgit/aports/plain/main/openldap/openldap-2.4-ppolicy.patch?h=3.2-stable -o /tmp/openldap-2.4-ppolicy.patch \
 && curl -fL http://git.alpinelinux.org/cgit/aports/plain/main/openldap/openldap-2.4.11-libldap_r.patch?h=3.2-stable -o /tmp/openldap-2.4.11-libldap_r.patch \
 && curl -fL http://git.alpinelinux.org/cgit/aports/plain/main/openldap/openldap-mqtt-overlay.patch?h=3.2-stable -o /tmp/openldap-mqtt-overlay.patch \
 && tar -xzf /tmp/openldap.tgz --strip=1 -C /tmp/openldap \
 && cd /tmp/openldap \
 && for p in /tmp/*.patch; do patch -p1 -i $p || true; done \
 && rm -vrf /etc/openldap/schema /usr/sbin/slap* /usr/lib/slap* \
 && ./configure \
        --prefix=/usr \
        --libexecdir=/usr/lib \
        --sysconfdir=/etc \
        --mandir=/tmp/man \
        --localstatedir=/var/lib/openldap \
        --enable-crypt \
        --enable-dynamic \
        --enable-modules \
        --enable-local \
        --enable-slapd \
        --enable-spasswd \
        --enable-bdb=mod \
        --enable-hdb=mod \
        --enable-dnssrv=mod \
        --enable-ldap=mod \
        --enable-meta=mod \
        --enable-monitor=mod \
        --enable-null=mod \
        --enable-passwd=mod \
        --enable-relay=mod \
        --enable-shell=mod \
        --enable-sock=mod \
        --enable-sql=mod \
        --enable-overlays=mod \
        --with-tls=openssl \
        --with-cyrus-sasl \
 && make \
 && make install \
 && cd contrib/slapd-modules/mqtt \
 && make prefix=/usr libexec=/usr/lib \
 && make prefix=/usr libexec=/usr/lib install \
 && cd /usr/sbin && ln -vs ../lib/slapd \
 && chown -vR ldap:ldap \
        /etc/openldap \
        /var/lib/openldap \
 && apk del --purge \
        gettext \
        ${BUILD_DEPS} \
 && mv -vf /etc/openldap/ldap.conf /etc/openldap/ldap.conf.original \
 && mv -vf /etc/openldap/slapd.conf /etc/openldap/slapd.conf.original \
 && echo "mech_list: plain external" > /etc/openldap/sasl2/slapd.conf \
 && rm -vfr \
        /tmp/* \
        /usr/share/man/* \
        /var/tmp/* \
        /var/cache/apk/*

EXPOSE 389

ENTRYPOINT ["/srv/openldap.sh"]
CMD ["slapd", "-h", "ldapi:/// ldap:///", "-u", "ldap", "-g", "ldap", "-d", "none"]
