# Pull base image
FROM node:0.12.7

# Pull Yeoman Generator
RUN npm install -g yo grunt-cli bower generator-angular-fullstack

# Prevent Build Error
RUN npm install -g node-gyp

# Define working directory
RUN mkdir /app
WORKDIR /app

# npm install
COPY package.json /app/package.json
RUN npm install

# bower install
COPY .bowerrc /app/.bowerrc
COPY bower.json /app/bower.json
RUN bower install --allow-root

# add application code
COPY . /app/

# build it
RUN NODE_ENV=production grunt build

# Define default command
CMD ["npm", "start"]