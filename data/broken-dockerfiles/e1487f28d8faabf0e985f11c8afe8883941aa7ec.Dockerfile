#
# Scala and sbt Dockerfile
#
# original file from
# https://github.com/hseeberger/scala-sbt
#

# Pull base image
FROM openjdk:8

# Env variables
ENV SCALA_VERSION 2.12.4
ENV SBT_VERSION   1.0.2
ENV APP_NAME      sf-xmas
ENV APP_VERSION   1.0-SNAPSHOT

# Scala expects this file
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion

# Install node and npm
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash && \
    apt-get install -y nodejs npm build-essential

# Define working directory
WORKDIR /root
ENV PROJECT_HOME /usr/src

COPY ["build.sbt", "/tmp/build/"]
COPY ["project/plugins.sbt", "project/build.properties", "/tmp/build/project/"]
RUN cd /tmp/build && \
 sbt update && \
 sbt compile

RUN mkdir -p $PROJECT_HOME/app
RUN mkdir -p $PROJECT_HOME/app/front-end

WORKDIR $PROJECT_HOME/app

# Run install scripts for grunt / npm etc
COPY /front-end/package.json $PROJECT_HOME/app/front-end
RUN cd front-end; npm install; npm install -g grunt-cli;

COPY . $PROJECT_HOME/app

RUN cd front-end; grunt;
RUN sbt test dist

# We are running play on this port so expose it
EXPOSE 9000
# Expose this port if you want to enable remote debugging: 5005

# Unzip the package
RUN unzip target/universal/$APP_NAME-$APP_VERSION.zip

# Update permissions
RUN chmod +x $APP_NAME-$APP_VERSION/bin/sf-xmas

# This will run at start, it points to the .sh file in the bin directory to start the play app
ENTRYPOINT $APP_NAME-$APP_VERSION/bin/sf-xmas
# Add this arg to the script if you want to enable remote debugging: -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005