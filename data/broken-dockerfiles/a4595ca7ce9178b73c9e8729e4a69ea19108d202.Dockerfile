FROM		hauptmedia/mariadb:10.0-galera
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

# install required packages 
RUN		apt-get update -qq && \
		apt-get install -y --no-install-recommends bzip2 && \
                apt-get clean autoclean && \
                apt-get autoremove --yes && \
                rm -rf /var/lib/{apt,dpkg,cache,log}/

ENV		GO_CRON_VERSION v0.0.7

RUN		curl -L https://github.com/odise/go-cron/releases/download/${GO_CRON_VERSION}/go-cron-linux.gz \
		| zcat > /usr/local/bin/go-cron \
		&& chmod u+x /usr/local/bin/go-cron

# install s3cmd
RUN		apt-get update -qq && \
                wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | apt-key add - && \
		wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list && \
		apt-get install -y --no-install-recommends s3cmd && \
                apt-get clean autoclean && \
                apt-get autoremove --yes && \
                rm -rf /var/lib/{apt,dpkg,cache,log}/

# install backup scripts
ADD		backup-galera-xtrabackup-v2 /usr/local/bin/backup-galera-xtrabackup-v2
ADD		backup-mysqldump /usr/local/bin/backup-mysqldump
ADD		backup-run /usr/local/bin/backup-run

#18080 http status port
EXPOSE		18080

ADD		docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh
ENTRYPOINT	["/usr/local/sbin/docker-entrypoint.sh"]

CMD		["go-cron"]
