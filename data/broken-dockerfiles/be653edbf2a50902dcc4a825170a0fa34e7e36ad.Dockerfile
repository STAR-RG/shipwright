FROM ubuntu:14.04

RUN apt-get update -yq && apt-get upgrade -yq && \
    apt-get install -yq curl git ssh sshpass
RUN apt-get -q -y install nodejs npm build-essential
RUN ln -s "$(which nodejs)" /usr/bin/node
RUN npm install -g npm bower grunt-cli gulp

# copy app and install deps
COPY . /src
RUN cd /src; npm install

EXPOSE 9000
CMD [ "node", "/src/app.js" ]

