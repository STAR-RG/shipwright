FROM node:latest

EXPOSE  7000

ENV appdir /app

ENV NODE_ENV production

ADD package.json $appdir/package.json

RUN cd /app && npm install

ADD . $appdir

WORKDIR ${appdir}

RUN npm run build

VOLUME ${appdir}/dist

VOLUME ${appdir}/.config

CMD ["start"]

ENTRYPOINT ["npm"]
