FROM ubuntu:latest

# Config
ENV USER_NAME devlob
ENV NODE_VERSION 4.3.2

# Setup dependencies
RUN apt-get update && apt-get install -y curl git python-pip

RUN groupadd $USER_NAME && useradd -m -g $USER_NAME $USER_NAME
USER $USER_NAME

# Install AWS CLI tools
RUN pip install awscli
ENV PATH $PATH:/home/$USER_NAME/.local/bin/

# Install AWS Lambda node version
ENV NVM_DIR /home/$USER_NAME/.nvm
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $PATH:$NVM_DIR/versions/node/v$NODE_VERSION/bin
RUN git clone https://github.com/creationix/nvm.git "$NVM_DIR" && \
  cd "$NVM_DIR" && \
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin` && \
  . "$NVM_DIR/nvm.sh" && \
  nvm install $NODE_VERSION && \
  npm install -g yarn
