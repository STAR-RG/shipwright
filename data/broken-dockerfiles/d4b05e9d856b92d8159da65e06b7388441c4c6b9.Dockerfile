FROM node:8 AS base

WORKDIR /app
COPY package*.json ./
RUN npm ci --production
RUN cp -R node_modules prod_node_modules
RUN npm ci
COPY . .
RUN npm run build-css && \
  npm run build-lib && \
  npm run build-template && \
  npm run build-app


FROM node:alpine
WORKDIR /usr/src/app
COPY --from=base /app/client/bundle ./client/bundle
COPY --from=base /app/prod_node_modules ./node_modules
COPY package.json ./
COPY client/index.html ./client/
COPY ./server ./server
COPY ./provider ./provider
COPY ./core ./core
VOLUME /var/data

EXPOSE 8000
CMD [ "./server/index.js" ]
