FROM nodesource/node:5

WORKDIR /code

ADD package.json /code/package.json

RUN npm config set production && npm install

ADD . /code

EXPOSE 8000

CMD [ "npm", "start" ]
