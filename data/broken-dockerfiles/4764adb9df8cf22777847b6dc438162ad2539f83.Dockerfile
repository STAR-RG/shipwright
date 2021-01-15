FROM node:10.0
COPY . /src
WORKDIR /src
RUN npm install --registry=https://registry.npm.taobao.org
EXPOSE 8080
