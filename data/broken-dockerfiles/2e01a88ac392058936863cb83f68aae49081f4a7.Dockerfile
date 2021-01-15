FROM node:10.18.0

WORKDIR /usr/src/app

COPY package*.json /usr/src/app/
RUN npm install

COPY . .

CMD [ "npm", "run", "nodemon" ]