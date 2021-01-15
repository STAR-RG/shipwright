# Mapnik for Docker

FROM ubuntu:16.04
MAINTAINER Fabien Reboia<srounet@gmail.com>

ENV LANG C.UTF-8
ENV MAPNIK_VERSION 3.0.10
RUN update-locale LANG=C.UTF-8

# Update and upgrade system
RUN apt-get -qq update && apt-get -qq --yes upgrade

# Essential stuffs
RUN apt-get -qq install --yes build-essential openssh-server sudo software-properties-common curl

# Boost
RUN apt-get -qq install -y libboost-dev libboost-filesystem-dev libboost-program-options-dev libboost-python-dev libboost-regex-dev libboost-system-dev libboost-thread-dev

# Mapnik dependencies
RUN apt-get -qq install --yes libicu-dev libtiff5-dev libfreetype6-dev libpng12-dev libxml2-dev libproj-dev libsqlite3-dev libgdal-dev libcairo-dev python-cairo-dev postgresql-contrib libharfbuzz-dev

# Mapnik 3.0.9
RUN curl -s https://mapnik.s3.amazonaws.com/dist/v${MAPNIK_VERSION}/mapnik-v${MAPNIK_VERSION}.tar.bz2 | tar -xj -C /tmp/ && cd /tmp/mapnik-v${MAPNIK_VERSION} && python scons/scons.py configure JOBS=4 && make && make install JOBS=4

# TileStache and dependencies
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib
RUN cd /tmp/ && curl -Os https://bootstrap.pypa.io/get-pip.py && python get-pip.py
RUN apt-get install python-pil
RUN pip install -U modestmaps simplejson werkzeug tilestache --allow-external PIL --allow-unverified PIL
RUN mkdir -p /etc/tilestache
COPY etc/run_tilestache.py /etc/tilestache/


# Uwsgi
RUN pip install uwsgi
RUN mkdir -p /etc/uwsgi/apps-enabled
RUN mkdir -p /etc/uwsgi/apps-available
COPY etc/uwsgi_tilestache.ini /etc/uwsgi/apps-available/tilestache.ini
RUN ln -s /etc/uwsgi/apps-available/tilestache.ini /etc/uwsgi/apps-enabled/tilestache.ini

# Supervisor
RUN pip install supervisor
RUN echo_supervisord_conf > /etc/supervisord.conf && printf "[include]\\nfiles = /etc/supervisord/*" >> /etc/supervisord.conf
RUN mkdir -p /etc/supervisord
COPY etc/supervisor_uwsgi.ini /etc/supervisord/uwsgi.ini
COPY etc/supervisor_inet.conf /etc/supervisord/inet.conf
COPY etc/init_supervisord /etc/init.d/supervisord
RUN chmod +x /etc/init.d/supervisord

# Nginx
RUN add-apt-repository -y ppa:nginx/stable && apt-get -qq update && apt-get -qq install -y nginx
COPY etc/nginx_site.conf /etc/nginx/sites-available/site.conf
RUN ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# SSH config
RUN mkdir /var/run/sshd
RUN echo 'root:toor' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Start services
RUN /etc/init.d/supervisord start
RUN service nginx start

EXPOSE 22 80 9001

ENV HOST_IP `ifconfig | grep inet | grep Mask:255.255.255.0 | cut -d ' ' -f 12 | cut -d ':' -f 2`

ADD start.sh /
RUN chmod +x /start.sh

CMD ["/start.sh"]
