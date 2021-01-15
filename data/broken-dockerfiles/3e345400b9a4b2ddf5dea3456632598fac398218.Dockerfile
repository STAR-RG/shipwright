FROM moul/node
MAINTAINER Manfred Touron "m@42.am"

RUN apt-get -qq -y install make gcc g++ && \
    apt-get clean

ADD package.json /app/package.json
WORKDIR /app
RUN npm install --production

ADD . /app/
ENTRYPOINT ["node", "bin/xbmc-remote-keyboard"]
CMD ["-h"]
