# FROM ubuntu:14.04
FROM debian:jessie
MAINTAINER JoongSeob Vito Kim <dorajissanai@nate.com>

# Run upgrades and install basic packages
RUN apt-get update && apt-get -qq -y install \
    git \
    curl \
    build-essential \
    libssl-dev \
    nodejs \
    python-dev \
    libevent-dev \
    python-software-properties \
    libmysqlclient-dev \
    python-mysqldb \
    python-software-properties \
    nginx \
    supervisor \
    python-pip \
    uuid-runtime 

ENV LC_ALL C.UTF-8

RUN git clone https://github.com/creationix/nvm.git
ENV NODE_VERSION v0.11.13
RUN echo 'source /nvm/nvm.sh && nvm install ${NODE_VERSION}' | bash -l
ENV PATH /nvm/${NODE_VERSION}/bin:${PATH}
RUN npm install -g grunt-cli
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
  sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf && \
  echo "mysqld_safe &" > /tmp/config && \
  echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
  echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
  echo "mysql -uroot -e 'create database fcib_dev'" >> /tmp/config && \
  bash /tmp/config && \
  rm -f /tmp/config


RUN git clone https://github.com/dorajistyle/flask-canjs-i18n-boilerplate.git
RUN mkdir logs
WORKDIR /flask-canjs-i18n-boilerplate/application/frontend/compiler
RUN npm install can-compile --save-dev && \
    npm install grunt-shell --save-dev && \
    npm install grunt-contrib-watch --save-dev && \
    npm install grunt-uncss --save-dev && \
    npm install time-grunt --save-dev

WORKDIR /flask-canjs-i18n-boilerplate
RUN pip install -r requirements.txt && \
    bash optimize_static.sh
RUN /usr/bin/mysqld_safe & \
    sleep 10s && \
    python alembic_upgrade.py && \
    python manage.py init_user
EXPOSE 5000
ENTRYPOINT ["./run_server.sh"]
