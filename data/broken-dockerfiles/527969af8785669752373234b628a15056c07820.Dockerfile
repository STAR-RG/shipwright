FROM node:carbon

# install pm2
RUN npm install pm2 -g

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json yarn.lock ./

# install all deps
ARG NPM_TOKEN
RUN echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" >> .npmrc
RUN yarn install --production=false

# Bundle app source
COPY . .

# build lib
RUN npm run build:prod

# install prod only this time
RUN yarn install --production=true

# delete .npmrc
RUN rm -f .npmrc

# delete app src
RUN rm -rf src

EXPOSE 1234
CMD [ "pm2-docker", "lib/bin/www.js" ]
