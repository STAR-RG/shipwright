FROM geodata/gdal

USER root

RUN apt-get install -y curl

RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

RUN echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

RUN apt-get install -y \
  make \
  gcc \
  g++ \
  curl \
  git \
  unzip \
  zlib1g-dev \
  nodejs \
  mongodb-org-shell \
  mongodb-org-tools

WORKDIR /data

ADD package.json .

RUN npm install

ADD . .

CMD /bin/true
