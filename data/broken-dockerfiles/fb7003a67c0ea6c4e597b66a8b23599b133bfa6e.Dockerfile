FROM fedora:23
MAINTAINER Si Beaumont <simon.beaumont@citrix.com>

# package installation
RUN dnf update -qy
RUN dnf install -qy https://s3.amazonaws.com/influxdb/influxdb-0.9.4-1.x86_64.rpm
RUN dnf install -qy https://grafanarel.s3.amazonaws.com/builds/grafana-2.1.3-1.x86_64.rpm
RUN dnf install -qy nginx
RUN dnf install -qy supervisor
RUN dnf install -qy cronie
RUN dnf install -qy nmap-ncat
RUN pip install -q requests
RUN pip install -q jira
RUN pip install -q pep8
RUN pip install -q pylint
RUN pip install -q demjson

# influxdb
ADD ./influxdb/init.sh /init-influxdb.sh
RUN bash /init-influxdb.sh

# grafana
ADD ./grafana/init.sh /init-grafana.sh
RUN bash /init-grafana.sh
ADD ./grafana/grafana.ini /etc/grafana/grafana.ini

# nginx config
ADD ./nginx/nginx.conf /etc/nginx/nginx.conf

# supervisord
ADD ./supervisord.conf /etc/supervisord.d/supervisord.conf

# scripts to generate data
ADD ./scripts/ /scripts/
ADD ./crontab-entries /etc/cron.d/data-scripts

# import grafana dashboard
ADD ./grafana/dash.json /var/lib/grafana/dashboards/dash.json

# expose ports for nginx (grafana)
EXPOSE 80

# expose influxdb data for creating a data volume container
VOLUME /var/opt/influxdb/

# run
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.d/supervisord.conf"]
