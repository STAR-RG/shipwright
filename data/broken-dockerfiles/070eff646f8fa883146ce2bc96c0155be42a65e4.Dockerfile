FROM circleci/node:latest-browsers

WORKDIR /usr/src/app/
USER root
COPY package.json ./
RUN yarn

COPY ./ ./

RUN yarn run build:prod

RUN ls app/public/local

EXPOSE 7001

CMD ["yarn", "run", "start"]