FROM ubuntu:latest
MAINTAINER Ori Pekelman <ori@pekelman.com>
# We need mongodb
# Add 10gen official apt source to the sources list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

# Hack for initctl not being available in Ubuntu
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl
# Install MongoDB
RUN apt-get update

#We ran into some weird shit starting mongo so this is the dance around locales
RUN apt-get -y install language-pack-en-base
RUN dpkg-reconfigure locales
RUN echo "export LC_ALL=C">> /etc/environment
RUN apt-get install mongodb-10gen
# Create the MongoDB data directory
RUN mkdir -p /data/db
#We need hadoop it, has dependencies
#RUN apt-get install -y rsync ssh
RUN apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository ppa:hadoop-ubuntu/stable
RUN apt-get update
RUN apt-get -y install hadoop

#We want to be able to ssh in
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN mkdir ~/.ssh/
RUN ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
RUN cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
RUN echo 'root:changeme' |chpasswd

ADD PredictionIO-0.6.3.zip /tmp/PredictionIO-0.6.3.zip
RUN apt-get install unzip
RUN cd /tmp && unzip PredictionIO-0.6.3.zip
RUN rm /tmp/PredictionIO-0.6.3.zip 
RUN mv /tmp/PredictionIO-0.6.3 /var/lib/predictionio
RUN apt-get -y install curl
RUN /usr/bin/mongod --config /etc/mongodb.conf --fork && sleep 1 && /var/lib/predictionio/bin/setup.sh


RUN apt-get install -y python-setuptools
RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /usr/local/etc/supervisord.conf


EXPOSE 27017 22 8000
CMD  ["/usr/local/bin/supervisord", "-n"]
