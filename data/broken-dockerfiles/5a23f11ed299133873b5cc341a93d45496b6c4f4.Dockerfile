# docker-pureftpd
# Copyright (C) 2016  gimoh
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM alpine:3.3
MAINTAINER gimoh <gimoh@bitmessage.ch>

ENV PUREFTPD_VERSION=1.0.42-r0 \
    SYSLOG_STDOUT_VERSION=1.1.1 \
    PURE_CONFDIR=/etc/pureftpd

RUN url_join() { local pifs="${IFS}"; IFS=/; echo "$*"; IFS="${pifs}"; } \
    && printf '%s\n' \
      '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' \
      >> /etc/apk/repositories \
    && apk update \
    && apk add pure-ftpd@testing="${PUREFTPD_VERSION}" \
    && apk add curl=7.49.1-r0 \
    && install -d -o root -g root -m 755 /usr/local/sbin \
    && curl -ksL \
      "$(url_join \
        https://github.com/timonier/syslog-stdout/releases/download \
        "v${SYSLOG_STDOUT_VERSION}" \
        syslog-stdout.tar.gz)" \
      |tar -xvzf - -C /usr/local/sbin \
    && apk del --purge curl \
    && rm -rf /var/cache/apk/*

# user ftpv and /srv/ftp for virtual users, user ftp and /var/lib/ftp
# for anonymous; these are separate so anonymous cannot read/write
# virtual users' files (if both enabled)
RUN adduser -D -h /dev/null -s /etc ftpv \
    && install -d -o root -g root -m 755 ~ftp /srv/ftp

COPY pure_defaults.sh /etc/profile.d/
COPY dkr-init.sh /usr/local/sbin/dkr-init
COPY adduser-ftp.sh /usr/local/bin/adduser-ftp

ENTRYPOINT ["/usr/local/sbin/dkr-init"]
