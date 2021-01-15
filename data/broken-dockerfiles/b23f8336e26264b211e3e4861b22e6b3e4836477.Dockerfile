FROM node:4.4

RUN npm install -g npm

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# you can change this at build time to control npm packages
# use this to build for prod: --build-arg NODE_ENV=production
ARG NODE_ENV=development

# this is the fallack dev/staging GA code, and should be replaced in prod at runtime
ARG GOOGLE_ANALYTICS=UA-39303796-11

COPY package.json /usr/src/app/
RUN npm install
COPY . /usr/src/app
RUN npm run build

EXPOSE 8000

CMD ["npm", "start"]
