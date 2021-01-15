FROM debian:stable
MAINTAINER Kai Kretschmann

#RUN apt-get update -y
RUN apt-get install -y mysql-server apache2 php-mysql php-gd
RUN a2enmod rewrite
RUN a2enmod headers
RUN service apache2 restart

ADD install.sh /
RUN chmod 755 /install.sh

EXPOSE 80

CMD ["/bin/bash", "/install.sh"]

# docker build -t lggr/test .
# docker run -p 4000:80 lggr/test
# docker container rm cea8...
# docker container rm lggr/test
#