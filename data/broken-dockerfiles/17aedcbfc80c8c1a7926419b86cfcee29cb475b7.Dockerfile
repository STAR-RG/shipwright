FROM hpess/chef:master

# add the patch file
COPY patch.txt /usr/local/src/patch.txt

# Install pre-reqs
RUN yum -y -q install perl-Crypt-OpenSSL-X509 openssl openssl-devel gcc gcc-c++ patch python dnsmasq net-tools telnet bind-utils && \
    cd /usr/local/src && \
    wget -q http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.0.4.tar.gz && \
    tar -xzf squid-3.5.0.4.tar.gz && \
    rm squid-3.5.0.4.tar.gz && \  
    patch -p1 < patch.txt && \
    cd squid-3.5.0.4 && \
    ./configure --disable-arch-native --build=x86_64-redhat-linux-gnu --host=x86_64-redhat-linux-gnu --prefix=/usr  --includedir=/usr/include  --datadir=/usr/share  --bindir=/usr/sbin  --libexecdir=/usr/lib/squid  --localstatedir=/var  --sysconfdir=/etc/squid --enable-icap --enable-ssl --enable-ssl-crtd --enable-delay-pools --with-openssl --enable-eui  --enable-follow-x-forwarded-for --enable-auth --enable-auth-basic=DB,LDAP,MSNT,MSNT-multi-domain,NCSA,NIS,PAM,POP3,RADIUS,SASL,SMB,getpwnam --enable-auth-ntlm=smb_lm,fake --enable-auth-digest=file,LDAP,eDirectory --enable-auth-negotiate=kerberos --enable-external-acl-helpers=file_userip,LDAP_group,time_quota,session,unix_group,wbinfo_group --enable-cache-digests --enable-cachemgr-hostname=localhost --enable-delay-pools --enable-epoll --enable-icap-client --enable-ident-lookups --enable-linux-netfilter --enable-removal-policies=heap,lru --enable-snmp --enable-ssl --enable-ssl-crtd --enable-storeio=aufs,diskd,ufs --enable-wccpv2 --enable-esi --with-aio --with-default-user=squid --with-filedescriptors=16384 --with-dl && \
    make && \
    make install && \
    rm -rf /usr/local/src/squid-3.5.0.4 && \
    yum -y -q autoremove openssl-devel gcc gcc-c++ patch && \
    yum -y -q clean all

# Setup squid
RUN useradd -M squid && \
    /usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db && \
    mkdir -p /var/cache/squid && \
    mkdir -p /etc/squid/ssl_cert && \
    mkdir -p /var/log/squid && \
    cd /etc/squid/ssl_cert && \
    chown -R squid:squid /var/cache/squid && \
    chown -R squid:squid /etc/squid && \
    chown -R squid:squid /var/log/squid && \
    chown -R squid:squid /var/lib/ssl_db && \
    setcap 'cap_net_bind_service=+ep' /usr/sbin/dnsmasq

# Set the chef local run list
ENV chef_node_name proxy.docker.local
ENV chef_run_list squid,dnsmasq,iptables

# Add the cookbooks
COPY cookbooks/ /chef/cookbooks/
