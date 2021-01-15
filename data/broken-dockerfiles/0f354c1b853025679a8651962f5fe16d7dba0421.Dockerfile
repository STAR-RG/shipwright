FROM node:8

RUN mkdir /app

WORKDIR  /app

COPY ./ ./

ENV NPM_CONFIG_LOGLEVEL warn

RUN npm i

RUN npm run build

EXPOSE 4000

CMD ["npm", "run", "serve"]
