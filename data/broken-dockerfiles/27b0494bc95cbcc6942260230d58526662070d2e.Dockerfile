FROM morecobol/gnucobol

# install node and other sys dependencies
RUN apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -y nodejs

WORKDIR /usr/src/app
COPY . .
RUN rm -rf node_modules
RUN npm install

CMD [ "npm", "start" ]
