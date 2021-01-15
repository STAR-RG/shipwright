# Pull base image.
FROM node:6.2.2

LABEL maintainer="Mumshad Mannambeth" maintainer_email="mmumshad@gmail.com"
LABEL Description="This image is used to start the ansible-playable web server. The image contains a built-in mongodb database, can mount Amazon S3 instance and runs the playable web server on MEAN stack." Version="alpha"

# Reset Root Password
RUN echo "root:P@ssw0rd@123" | chpasswd

# Install Ansible
RUN apt-get update && \
    apt-get install python-setuptools python-dev build-essential -y && \
    easy_install pip && \
    pip install ansible && \
    pip install pyOpenSSL==16.2.0

# -----------------------------------------------------------

# Install MongoDB
# 1. Import the public key
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6

# 2. Add source info
RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list

# 3. Update apt and install MongoDB
RUN apt-get update && apt-get install -y mongodb-org

# -----------------------------------------------------------

# TO fix a bug
RUN mkdir -p /root/.config/configstore && chmod g+rwx /root /root/.config /root/.config/configstore
RUN useradd -u 1003 -d /home/app_user -m -s /bin/bash -p $(echo P@ssw0rd@123 | openssl passwd -1 -stdin) app_user

# Create data directory
RUN mkdir -p /data

RUN chown -R app_user /usr/local && chown -R app_user /home/app_user && chown -R app_user /data

# Install VIM and Openssh-Server
RUN apt-get update && apt-get install -y vim openssh-server

# Permit Root login
RUN sed -i '/PermitRootLogin */cPermitRootLogin yes' /etc/ssh/sshd_config

# Generate SSH Keys
RUN /usr/bin/ssh-keygen -A

# Start Open-ssh server
RUN service ssh start

# Install YAS3FS for mounting AWS Bucket
RUN apt-get update -q && apt-get install -y python-pip fuse \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/*
RUN pip install yas3fs
RUN sed -i'' 's/^# *user_allow_other/user_allow_other/' /etc/fuse.conf # uncomment user_allow_other
RUN chmod a+r /etc/fuse.conf # make it readable by anybody, it is not the default on Ubuntu

# Install NPM dependencies
RUN npm install -g yo gulp-cli generator-angular-fullstack

# Change user to app_user
USER app_user

RUN mkdir -p /data/web-app
COPY ./package.json /data/web-app
WORKDIR /data/web-app

# Assign permissions to app_user
USER root
RUN chown -R app_user /data/web-app

# Change user to app_user
USER app_user

RUN npm install

# Copy all application files
COPY ./ /data/web-app

# Assign permissions to app_user
USER root
RUN chown -R app_user /data/web-app

RUN mkdir -p /data/db

RUN gulp build

# Create empty logs directory
RUN mkdir -p logs

# Provide execute permissions for startup script
RUN chmod 755 helpers/startup.sh

# Create ansible-projects folder if it doesn't already exist
RUN mkdir -p /opt/ansible-projects

# Start services and start web server
ENTRYPOINT helpers/startup.sh
