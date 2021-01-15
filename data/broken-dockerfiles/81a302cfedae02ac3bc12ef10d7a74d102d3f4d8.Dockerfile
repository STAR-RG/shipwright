FROM node:latest

RUN apt-get update -qq
# RUN add-apt-repository -y ppa:kubuntu-ppa/backports
RUN apt-get update
RUN apt-get install --force-yes --yes libcv-dev libcvaux-dev libhighgui-dev libopencv-dev

RUN mkdir node_modules
RUN npm install mocha nierika rfb2

CMD /node_modules/.bin/mocha /test
