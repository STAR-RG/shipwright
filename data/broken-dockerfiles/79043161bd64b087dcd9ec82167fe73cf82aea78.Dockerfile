FROM ubuntu:latest

RUN apt-get update -y && apt-get upgrade -y \
  && apt-get install -y screen rsync curl git python-dev python-pip

# upgrade pip
RUN pip install --upgrade pip

# install Node.js and update npm
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install -y nodejs build-essential \
  && npm install npm@latest -g

# install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# install awscli
RUN pip install awscli

# install the Serverless Framework
RUN npm install --global serverless
