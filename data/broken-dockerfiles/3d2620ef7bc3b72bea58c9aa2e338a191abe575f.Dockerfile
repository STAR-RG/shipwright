# An example Ubuntu container for a web application
FROM ubuntu
MAINTAINER Paul Willoughby <paul@fivetide.com>

# Update sources
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

# Required packages
RUN apt-get install -y apache2
RUN apt-get install -y php5

# Start Apache and expose port
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
EXPOSE 80
ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-D", "FOREGROUND"]
