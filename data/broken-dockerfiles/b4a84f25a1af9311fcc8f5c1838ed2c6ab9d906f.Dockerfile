FROM node:7.10-wheezy
RUN mkdir /app
WORKDIR /app

RUN npm install -g truffle
RUN npm install truffle-hdwallet-provider

COPY contracts ./contracts/
COPY installed_contracts ./installed_contracts/
COPY truffle.js truffle.js
COPY ethpm.json ethpm.json

RUN truffle compile
RUN truffle publish -n ropsten
