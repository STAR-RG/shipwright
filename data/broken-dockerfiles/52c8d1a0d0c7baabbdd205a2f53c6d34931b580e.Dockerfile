FROM node:8-alpine
MAINTAINER Jeremy Shimko <jeremy@reactioncommerce.com>

ARG NODE_ENV=production

ENV APP_SOURCE_DIR=/opt/src \
    NODE_ENV=$NODE_ENV \
    PATH=$PATH:/opt/node_modules/.bin

WORKDIR $APP_SOURCE_DIR

# Build the dependencies into the Docker image in a cacheable way. Dependencies
# are only rebuilt when package.json or yarn.lock is modified.
#
# The project directory will be mounted during development. Therefore, we'll
# install dependencies into an external directory (one level up.) This works
# because Node traverses up the fs to find node_modules.
COPY package.json yarn.lock $APP_SOURCE_DIR/
RUN set -ex; \
  if [ "$NODE_ENV" = "production" ]; then \
    yarn install \
      --frozen-lockfile \
      --ignore-scripts \
      --modules-folder "$APP_SOURCE_DIR/../node_modules" \
      --no-cache \
      --production; \
  elif [ "$NODE_ENV" = "test" ]; then \
    yarn install \
      --frozen-lockfile \
      --ignore-scripts \
      --modules-folder "$APP_SOURCE_DIR/../node_modules" \
      --no-cache; \
  elif [ "$NODE_ENV" = "development" ]; then \
    yarn install \
      --cache-folder /home/node/.cache/yarn \
      --ignore-scripts \
      --modules-folder "$APP_SOURCE_DIR/../node_modules"; \
  fi; \
  rm package.json yarn.lock

COPY . $APP_SOURCE_DIR

RUN yarn run build

EXPOSE 3000

CMD ["node", "dist/index.js"]
