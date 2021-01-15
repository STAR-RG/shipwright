
FROM ubuntu:14.04

# statsd udp data (send rbx data to this port)
EXPOSE 8125/udp
# statsd management
EXPOSE 8126
# influxdb management UI
EXPOSE 8083
# influxdb API
EXPOSE 8086
# grafana dashboard UI
EXPOSE 80

# Install some basic utilities with the OS package manager
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y wget curl python-pip supervisor nginx-light npm
RUN pip install envtpl

# Install statsd and backend and configuration
RUN npm -g install statsd
RUN npm -g install statsd-influxdb-backend
ADD statsd/config.js /statsd/config.js
# Symbolic link because statsd expects a binary called `node`
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Install influxdb and setup script
RUN wget http://s3.amazonaws.com/influxdb/influxdb_latest_amd64.deb
RUN dpkg -i influxdb_latest_amd64.deb
ADD influxdb/setup.sh /influxdb/setup.sh
# Set up influxdb and create the databases
RUN influxdb/setup.sh

# Install grafana and configuration
RUN mkdir /src
RUN wget http://grafanarel.s3.amazonaws.com/grafana-1.9.0.tar.gz -O /src/grafana.tar.gz
RUN cd /src && tar -xvf grafana.tar.gz && mv grafana-1.9.0 grafana
ADD grafana/config.js.tpl /src/grafana/config.js.tpl
ADD grafana/rbx-dash.json /src/grafana/app/dashboards/rbx-dash.json
ADD grafana/setup.sh /src/grafana/setup.sh
# Add nginx configuration
ADD nginx/nginx.conf /etc/nginx/nginx.conf

# Add supervisord configuration and set default command for `docker run`
ADD supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
