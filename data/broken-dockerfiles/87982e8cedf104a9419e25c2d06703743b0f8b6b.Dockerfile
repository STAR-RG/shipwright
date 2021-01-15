FROM node:argon

RUN apt-get update
RUN apt-get install mongodb -y

RUN service mongodb start

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

ENV PORT 8080

EXPOSE 8080

RUN npm install
RUN npm run test
RUN npm run build
CMD ["node", "dist/server.js"]
