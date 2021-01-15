FROM node

RUN npm install -g yarn pm2 pino-pretty

LABEL description="A Express JS Kick Starter with Typescript, MongoDB and Docker" version="1.0.0" maintainer="Sami Henrique de França"

ENV API_PATH="/usr/src/expressjs/"

WORKDIR ${API_PATH}

COPY . ${API_PATH}

RUN chmod -R 777 ${API_PATH}

RUN yarn install

EXPOSE 3000

CMD ["yarn", "dev:docker"]
