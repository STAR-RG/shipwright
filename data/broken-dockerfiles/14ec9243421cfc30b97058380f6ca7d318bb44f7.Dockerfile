FROM tatsuru/debian
ENV PATH /usr/sbin:/sbin:/usr/bin:/bin

# do not ask
ENV DEBIAN_FRONTEND noninteractive

# update/install packages
RUN apt-get -f update
RUN apt-get install -y adduser bash openssh-server curl wget lsb-release build-essential libgmp3-dev libssl-dev libexpat1-dev libxml2-dev libmysqlclient-dev shared-mime-info libmagickcore-dev git supervisor telnet strace tcpdump uuid-runtime git

# perl-install
RUN wget -O /tmp/perl-install https://raw.github.com/tatsuru/xbuild/master/perl-install
RUN bash /tmp/perl-install 5.18.1 /opt/perl

# ruby-install
RUN wget -O /tmp/ruby-install https://raw.github.com/tatsuru/xbuild/master/ruby-install
RUN bash /tmp/ruby-install 2.0.0-p353 /opt/ruby
ENV PATH /opt/ruby/bin:/opt/perl/bin:/usr/sbin:/sbin:/usr/bin:/bin

RUN gem install fluentd

# sensu
RUN wget -q -O /tmp/sensu_0.12.2-1_amd64.deb  http://repos.sensuapp.org/apt/pool/sensu/main/s/sensu/sensu_0.12.2-1_amd64.deb
RUN dpkg -i /tmp/sensu_0.12.2-1_amd64.deb
RUN mkdir /var/run/sensu

# deploy
RUN mkdir -p /opt/Sampleapp
ADD . /opt/Sampleapp/current

# 差分で作れるようにrepository を向くようにする(これはちょっとひどい)
RUN cd /opt/Sampleapp/current && git config remote.origin.url https://github.com/tatsuru/docker-sample-app.git
RUN cd /opt/Sampleapp/current && git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'

# carton install
RUN mkdir /opt/Sampleapp/shared
RUN cd /opt/Sampleapp/current && carton install --deployment --path /opt/Sampleapp/shared

# log
RUN mkdir /var/log/app

RUN mkdir /root/.ssh
ADD key/authorized_keys /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys

# sensu
ADD sensu/config.json /etc/sensu/config.json
ADD sensu/handler.json /etc/sensu/conf.d/handler.json
ADD sensu/metric.json /etc/sensu/conf.d/metric.json

EXPOSE 8000
CMD ["/usr/bin/supervisord", "-c", "/opt/Sampleapp/current/supervisor/supervisord.conf"]
