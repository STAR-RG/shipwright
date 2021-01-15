FROM 		ubuntu:15.04
MAINTAINER Ash Prosser <ash@wearemothership.com>

#NodeJS
RUN apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs
RUN apt-get install -y build-essential

COPY ./package.json /var/www/nodeapp/package.json
WORKDIR /var/www/nodeapp/
RUN npm install --production

WORKDIR /var/www/nodeapp/app
ADD 	. /var/www/nodeapp/app

EXPOSE 		3000

CMD        	["npm", "run-script", "start"]