FROM node:0.12.4
MAINTAINER 540 Co LLC <info@540.co>

RUN mkdir -p /usr/src/dre
WORKDIR /usr/src/dre

RUN npm install -g bower grunt-cli mocha

RUN groupadd -r node \
&&  useradd -r -m -g node node

# Copy source
COPY . /usr/src/dre
RUN chown -R node:node /usr/src/dre

USER node

# Install client dependencies
WORKDIR /usr/src/dre/client
RUN npm install; bower install; grunt build

# Install server dependencies
WORKDIR /usr/src/dre/server
RUN npm install

# Expose port 3000 to host
EXPOSE 3000

# Start server
WORKDIR /usr/src/dre/server
CMD ["npm", "start"]

# How to build:
# git clone https://github.com/540co/ads-bpa.git
# cd ads-bpa
# docker build -t dre .

# How to run
# docker pull mongo
# docker run -d --name db mongo
# docker run -d --name dre -p 3000:3000 --link db:db dre
