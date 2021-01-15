FROM node:0.12.7-slim

RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get update && \
    apt-get install -y python make g++ git

WORKDIR /mconn
COPY . /mconn

RUN npm install -g coffee-script coffeelint grunt-cli bower mocha chai coffee-coverage istanbul && \
    npm install && \
    grunt build

EXPOSE 1234

CMD ["npm", "start"]
