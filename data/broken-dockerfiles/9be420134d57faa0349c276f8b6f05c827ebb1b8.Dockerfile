FROM ubuntu:latest
RUN apt update && apt upgrade -y
RUN apt install curl git wget -y
RUN apt install g++ make build-essential -y
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt install nodejs -y
RUN npm install -g n
RUN n 11.15.0
COPY . /usr/src/app/
RUN mkdir /usr/src/nVis
RUN cp -r /usr/src/app/bundle /usr/src/nVis/
WORKDIR /usr/src/nVis/bundle/programs/server
RUN npm install
WORKDIR /usr/src/nVis/bundle/
EXPOSE 3000
CMD PORT=3000 ROOT_URL=http://localhost:3000 MONGO_URL=mongodb://mongodb:27017/meteor node main.js
