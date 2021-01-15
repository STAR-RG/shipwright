FROM node:8.5.0

WORKDIR /app/

# Need .git so we can get the git head commit hash
COPY .git /app/.git
COPY .babelrc /app/.babelrc
COPY .solcover.js /app/.solcover.js
COPY .soliumrc.json /app/.soliumrc.json
COPY .soliumignore /app/.soliumignore
COPY .eslintrc.js /app/.eslintrc.js
COPY package.json /app/package.json
COPY contracts /app/contracts
COPY test /app/test
COPY utils /app/utils
COPY scripts /app/scripts
COPY migrations /app/migrations
COPY truffle.js /app/truffle.js

RUN npm install
RUN npm run compile
