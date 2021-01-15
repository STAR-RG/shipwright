FROM nimlang/nim:latest
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN nimble install --depsOnly --accept
RUN nimble build
RUN nimble install
