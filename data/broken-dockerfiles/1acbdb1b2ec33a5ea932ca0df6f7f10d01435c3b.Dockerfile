FROM registry.matchvs.com/language/nodejs:latest
WORKDIR /app
COPY package.json /app
RUN cnpm install
COPY . /app
CMD node main.js
