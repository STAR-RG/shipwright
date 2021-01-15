#
# Modified Nginx Dockerfile - nginx-full instead of nginx
#
# https://github.com/dockerfile/nginx
#

FROM ubuntu:14.04

# Install Nginx.
RUN \
  apt-get install -y software-properties-common wget && \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx-full && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx && \
  mkdir /etc/nginx/geoip && \
  cd /etc/nginx/geoip && \
  wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz && \
  gunzip GeoIP.dat.gz

# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443

COPY nginx.conf /etc/nginx/nginx.conf
#COPY mailsquad-com.crt /etc/nginx/mailsquad-com.crt
#COPY mailsquad-com.key  /etc/nginx/mailsquad-com.key
#COPY trustchain.crt /etc/nginx/trustchain.crt
#COPY dhparam.pem /etc/nginx/dhparam.pem

COPY html /usr/share/nginx/html