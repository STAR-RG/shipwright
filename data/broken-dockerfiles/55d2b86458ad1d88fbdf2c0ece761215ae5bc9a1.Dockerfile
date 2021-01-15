#base image
FROM node:0.12.4-slim

# Exclude npm cache from the image
VOLUME /root/.npm

#environment variables
ENV workdir /es6-promise-debounce

#add files ad set workdir
COPY . $workdir
WORKDIR $workdir

#install dependecys
RUN apt-get clean && apt-get update &&\
    apt-get install -y g++ python bzip2 libfreetype6 make libfontconfig curl &&\
    npm install -g node-gyp &&\
    npm install -g tape-run &&\
    npm install -g browserify &&\
    npm install -g phantomjs &&\
    npm install -g npm-check-updates && \
    npm install

#launch
CMD npm test
