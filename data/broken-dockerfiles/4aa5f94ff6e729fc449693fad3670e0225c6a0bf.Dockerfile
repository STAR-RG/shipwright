FROM resin/raspberrypi3-node:6

RUN apt-get update && apt-get install -yq libraspberrypi-bin

WORKDIR usr/src/app

COPY package.json ./
RUN JOBS=MAX npm i --production

COPY . ./

CMD npm start
