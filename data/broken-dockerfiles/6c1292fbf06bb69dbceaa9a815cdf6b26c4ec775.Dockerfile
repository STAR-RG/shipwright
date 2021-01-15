FROM node:7-slim
MAINTAINER MuzHack Team <contact@muzhack.com>

WORKDIR /app
ENTRYPOINT ["node", "dist/app/server.js"]
ENV PORT=80
EXPOSE 80

RUN apt-get update && apt-get install -y python-pip

# Cache dependencies in order to speed up builds
COPY package.json package.json
COPY requirements.txt requirements.txt
# Turn off production mode, as we need to install dev dependencies
ENV NODE_ENV=
RUN npm install
# Re-enable production mode
ENV NODE_ENV=production
RUN npm install -g gulp
RUN pip install -U pip
RUN pip install -U -r requirements.txt

RUN apt-get -y remove python-pip

COPY ./ .
RUN ./node_modules/.bin/webpack -p --devtool cheap-module-source-map
RUN gulp
