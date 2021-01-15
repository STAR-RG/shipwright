FROM node:8-alpine

WORKDIR /usr/src/app

COPY . /usr/src/app
RUN npm install
RUN npm run build

ENTRYPOINT [ "./index.js" ]
