FROM gliderlabs/alpine
RUN apk add --no-cache nodejs

ENV APP_DIR ~/src

COPY . $APP_DIR
RUN cd ${APP_DIR} && \
    npm i -g --production --quiet