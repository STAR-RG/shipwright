FROM openjdk:8

RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
  && curl https://bazel.build/bazel-release.pub.gpg | apt-key add -

RUN apt-get update \
  && apt-get install -y bazel \
  && rm -rf /var/lib/apt/lists/*

# Set up workspace
ENV WORKSPACE /usr/src/app
COPY . /usr/src/app
WORKDIR /usr/src/app

RUN bazel build quitsies

FROM debian:stretch

LABEL maintainer="Ashley Jeffs <ash.jeffs@gmail.com>"

WORKDIR /root/

COPY --from=0 /usr/src/app/bazel-bin/quitsies .

EXPOSE 3058
EXPOSE 11211

ENTRYPOINT ["./quitsies" ]

