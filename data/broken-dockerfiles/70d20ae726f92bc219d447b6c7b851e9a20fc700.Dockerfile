FROM node:8.2-alpine
COPY . /app
WORKDIR /app
RUN npm i -g nodemon typescript \
    && npm i \
    && tsc \
    && apk --update add git \
    && git clone https://github.com/terraform-providers/terraform-provider-aws.git
CMD node index.js