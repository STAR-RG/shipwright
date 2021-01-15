FROM ubuntu:15.04

# Install Nodejs, npm, git and ffmpeg

RUN apt-get update
RUN apt-get install -y nodejs npm git ffmpeg
RUN apt-get upgrade

# manually create a symlink /usr/bin/node
RUN ln -s `which nodejs` /usr/bin/node

# Copy entire project
ADD / /server

WORKDIR /
RUN npm install --production

EXPOSE 8000

# CMD [ "npm", "start" ]
