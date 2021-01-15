FROM node:7-alpine

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Bundle app source
COPY . /usr/src/app

# Install all dependencies, executes post-install script and remove deps
RUN npm install && npm cache clean && npm run build-front && rm -r node_modules

# Install app production only dependencies
RUN npm install --production && npm cache clean && cp -rp ./node_modules /tmp/node_modules

EXPOSE 3001

CMD [ "npm", "start" ]
