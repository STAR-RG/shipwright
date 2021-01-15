FROM node

# Create app directory
RUN mkdir -p /opt/src
WORKDIR /opt/src

# Install app dependencies
COPY package.json /opt/src/
RUN npm i yarn -g
RUN yarn install

# Bundle app source
COPY . /opt/src

EXPOSE 3000
CMD [ "npm", "start" ]
