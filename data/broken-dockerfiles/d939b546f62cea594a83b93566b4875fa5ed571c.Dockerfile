FROM ubuntu:16.04

EXPOSE 8887

RUN apt-get update
RUN apt-get install -y curl git

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g webpack

WORKDIR /
RUN git clone https://github.com/ilcic/pokemon-go-diary.git

WORKDIR /pokemon-go-diary
RUN npm install webpack
RUN npm install
RUN npm run ui-build
RUN npm run ui-install

WORKDIR /pokemon-go-diary
CMD ["npm", "start"]
