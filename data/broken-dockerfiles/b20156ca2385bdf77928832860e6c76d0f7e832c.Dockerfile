FROM mhart/alpine-node:5

WORKDIR /wdio-cucumber-reporter

ADD package.json /wdio-cucumber-reporter/
RUN npm install

ADD . /wdio-cucumber-reporter/

CMD "npm" "run" "test"
