FROM node:lts-alpine as builder

ENV APP_DIR=/src-blog

WORKDIR $APP_DIR

COPY package.json $APP_DIR/
COPY yarn.lock $APP_DIR/
RUN yarn

COPY . $APP_DIR/
RUN yarn start build blog

FROM nginx:alpine

COPY --from=builder /src-blog/public /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]