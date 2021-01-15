FROM node:4
MAINTAINER Jun Matsushita <jun@iilab.org>

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY . /usr/src/app

EXPOSE 3000
CMD [ "sh", "-c", "node_modules/.bin/gulp production && node_modules/.bin/serve -D -C --compress -f img/favicon.ico" ]
