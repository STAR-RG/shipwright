FROM ubuntu:latest
MAINTAINER Sreeja Kamishetty <sreeja25kamishetty@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

#Update
RUN apt-get update
RUN apt-get upgrade -y

#Install proper dependencies
RUN apt-get install -y git wget

#run the script
RUN apt-get install -y apache2
RUN apt-get install mysql-server php5-mysql
RUN  mysql_install_db
RUN apt-get install php5 libapache2-mod-php5 php5-mcrypt
RUN service apache2 restart
RUN apt-cache search php5-cgi

#Clone the source
RUN git clone https://github.com/fossasia/engelsystem.git

#cd into the dir
WORKDIR engelsystem
#add the mysql root password
COPY config/config.default.php config/config.php
RUN mysql -u root -p engelsystem < db/install.sql
RUN mysql -u root -p engelsystem < db/update.sql
EXPOSE 80
