FROM debian:jessie

MAINTAINER Samuel Terburg <samuel.terburg@panther-it.nl>

# admin password to login to directadmin console
ENV ADMIN_PASSWORD=da_wachtwoord

# UID & LID used to retreive directadmin license
ENV UID=1234
ENV LID=12345

# Interface to which the Directadmin licensed public ip-address is bound
ENV IF=bond0
#ENV HOSTNAME=web.dvbserver.nl

RUN apt-get update && \
    apt-get -y install gcc g++ make flex bison openssl libssl-dev perl perl-base perl-modules libperl-dev libaio1 libaio-dev zlib1g zlib1g-dev libcap-dev bzip2 automake autoconf libtool cmake pkg-config python libdb-dev libsasl2-dev libncurses5-dev libsystemd-dev bind9 quota libsystemd-daemon0 patch curl libhtml-parser-perl libdbi-perl libmodule-build-perl libcrypt-ssleay-perl libxml2-dev libmcrypt-dev libmcrypt4 libltdl-dev libltdl7 libfreetype6-dev libfreetype6 wget apt-utils libgd-perl libgd-dev psmisc libaio-dev libkrb5-3 libkrb5-dev cron liblwp-protocol-https-perl libnet-dns-perl liblwp-useragent-determined-perl libhttp-date-perl libmail-dkim-perl libio-socket-ssl-perl libencode-detect-perl libnet-patricia-perl libnetaddr-ip-perl libdigest-sha-perl libmail-spf-perl libgeo-ip-perl libnet-cidr-lite-perl razor libio-socket-inet6-perl libio-socket-ssl-perl inetutils-inetd xsltproc python-libxml2 openssh-client openssh-server


WORKDIR /usr/local/directadmin

COPY start.sh     /usr/local/bin/
COPY options.conf custombuild/

RUN echo 1   >/root/.lan && \
    echo 2.0 >/root/.custombuild && \
    echo "php_timezone=`cat /etc/timezone`" >>options.conf && \
    echo "redirect_host=$HOSTNAME"          >>options.conf && \
    curl -sSL http://www.directadmin.com/setup.sh | sh -x -s $UID $LID `hostname`.bridge $IF

#RUN curl -sSL http://files.directadmin.com/services/custombuild/2.0/custombuild.tar.gz |tar xz && \
#    cd custombuild && \
#    chmod +x build && \
#    sh -x ./build && \
#    sh -x ./build update_data && \
#    sh -x ./build all n
#   ./build rewrite_confs
#   ./build suphp

WORKDIR /usr/local/directadmin/data/admin
RUN echo -e "oversell=yes\nsuspend=no" >>admin.conf

# . /usr/local/directadmin/conf/mysql.conf #loading admin username/password
#    perl -pi -e 's/ADD_USERS_TO_LIST=.../ADD_USERS_TO_LIST="1"/' /usr/local/sysbk/conf.sysbk && \
#    echo "0 5 * * 0 /usr/local/sysbk/sysbk -q" >>/var/spool/cron/root
#    echo -e "gateway=\nnetmask=$NETMASK\nns=\nreseller=admin\nstatus=free\nvalue=" >admin/ips/$IP2
#    echo $IP2 >>admin/ip.list
#    perl -pi -e "s/ips=0/ips=3/" users/admin/reseller.conf
#    cd /usr/src/directadmin/
#    perl -pi -e "s/#ADMIN_PWD#/$passwd/"  *.php
#    perl -pi -e "s/#DOMAIN#/$domainname/" *.php
#    perl -pi -e "s/#IP#/$IP/"   *.php
#    perl -pi -e "s/#IP2#/$IP2/" *.php
#    /usr/local/php5/bin/php ./redmgt.php      >result.html; lynx -dump result.html |egrep "^          "  #Adding redmgt user
#    /usr/local/php5/bin/php ./firstdomain.php >result.html; lynx -dump result.html |egrep "^    "        #Adding primary domain
#    /usr/local/php5/bin/php ./nameservers.php >result.html; lynx -dump result.html |egrep "^    "        #Adding nameservers
#    /usr/local/php5/bin/php ./shareip.php     >result.html; lynx -dump result.html |tr "&" "\n" |grep "details" |sed "s/details=//"  #Share IP

WORKDIR /usr/local/directadmin/
RUN ./scripts/majordomo.sh
RUN ./scripts/spam.sh
#    /usr/bin/spamd -d -c -m 5
#    razor-admin -d -create
#    razor-admin -register
#    pyzor discover
#    cdcc "delete 127.0.0.1 Greylist"
#    cdcc "delete 127.0.0.1"
#    perl -pi -e "s/DCCIFD_ENABLE=off/DCCIFD_ENABLE=on/" /etc/dcc/dcc_conf
#    ln -s /usr/libexec/dcc/rcDCC /etc/init.d/DCC
#    chkconfig --add DCC
#    ln -s /usr/libexec/dcc/cron-dccd /usr/bin/cron-dccd
#    ln -s /usr/bin/cron-dccd /etc/cron.daily/cron-dccd
#    perl -pi -e "s/^debuglevel             = 3/debuglevel             = 1/" /root/.razor/razor-agent.conf
#    echo "razorhome = /etc/mail/spamassassin/.razor" >>/root/.razor/razor-agent.conf
#    echo "dcc_home /var/dcc" >>/etc/mail/spamassassin/local.cf
#    cp -r /root/.razor/ /etc/mail/spamassassin/
#    cp -r /root/.pyzor /etc/mail/spamassassin/
#    razor-admin -d -create -home=/etc/mail/spamassassin/.razor/
#    perl -pi -e "s/#loadplugin Mail::SpamAssassin::Plugin::Razor2/loadplugin Mail::SpamAssassin::Plugin::Razor2/" /etc/mail/spamassassin/v310.pre
#    perl -pi -e "s/#loadplugin Mail::SpamAssassin::Plugin::Pyzor/loadplugin Mail::SpamAssassin::Plugin::Pyzor/" /etc/mail/spamassassin/v310.pre
#    perl -pi -e "s/#loadplugin Mail::SpamAssassin::Plugin::DCC/loadplugin Mail::SpamAssassin::Plugin::DCC/" /etc/mail/spamassassin/v310.pre
#    sa-update

# Cleanup (Values set @ runtime)
RUN rm -f conf/license.key         && \
    echo >data/admin/ip.list       && \
    echo >data/users/admin/ip.list && \
    echo >data/users/admin/user_ip.list && \
    perl -pi -e "s/^ip=.*//g" data/users/admin/user.conf && \
    perl -pi -e "s/^ip=.*//g" scripts/setup.txt

RUN chown root  /usr/local/directadmin /etc -R && \
    chmod a+rwX /usr/local/directadmin /etc -R

CMD ["/usr/local/bin/start.sh"]
