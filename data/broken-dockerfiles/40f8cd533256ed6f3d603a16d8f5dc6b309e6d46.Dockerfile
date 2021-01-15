FROM ubuntu

# Install Wget
RUN apt-get -y install wget
# Install Node
RUN \
  cd /opt && \
  wget http://nodejs.org/dist/v0.10.28/node-v0.10.28-linux-x64.tar.gz && \
  tar -xzf node-v0.10.28-linux-x64.tar.gz && \
  mv node-v0.10.28-linux-x64 node && \
  cd /usr/local/bin && \
  ln -s /opt/node/bin/* . && \
  rm -f /opt/node-v0.10.28-linux-x64.tar.gz

# install nodemon & sequelize-cli globally
RUN npm install -g \
  nodemon \
  coffee-script \
  js2coffee \
  --save-dev

# Set the working directory
WORKDIR /src

CMD ["/bin/bash"]
