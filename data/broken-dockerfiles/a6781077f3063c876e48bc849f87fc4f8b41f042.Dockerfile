# base image
FROM node:12.2.0-alpine

# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# install and cache app dependencies
COPY package.json /app/package.json
RUN npm install 
RUN npm install --only=dev

COPY src/ /app/src
COPY public/ /app/public
COPY server/ /app/server
COPY .babelrc /app/.babelrc
COPY defaultConfig.yaml /app/defaultConfig.yaml


RUN npm run build


# start app
CMD ["npm", "run", "prod"]