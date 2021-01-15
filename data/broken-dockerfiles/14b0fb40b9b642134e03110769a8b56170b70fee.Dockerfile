FROM resin/rpi-raspbian:wheezy
MAINTAINER Julio César <julioc255io@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y build-essential
RUN apt-get install -y python
RUN apt-get install -y wget

# Install Nodejs 0.10.xx for compatibility with serialport
RUN wget http://node-arm.herokuapp.com/node_0.10.36-1_armhf.deb
RUN dpkg -i node_0.10.36-1_armhf.deb

# Install Arduino
RUN apt-get install -y --force-yes arduino

# Install node modules
WORKDIR /usr/src/voyager-bot/
COPY . /usr/src/voyager-bot/
RUN npm install

EXPOSE 3000

CMD ["node", "/usr/src/voyager-bot/app.js"]
