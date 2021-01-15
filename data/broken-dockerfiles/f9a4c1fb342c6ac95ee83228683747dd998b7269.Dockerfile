FROM java:latest
MAINTAINER Suneeta Mall "suneeta.mall@nearmap.com"

ENV SCALA_VERSION 2.11.8
ENV SBT_VERSION 0.13.12
ENV SCALA_INST /usr/local/share
ENV SCALA_HOME $SCALA_INST/scala

RUN apt-get -yqq update && apt-get -yqq upgrade && apt-get install -y --no-install-recommends \
  python-pip \
  awscli \
  less \
  curl \
  jq

RUN \
  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C $SCALA_INST && \
  ln -sf scala-$SCALA_VERSION $SCALA_HOME && \
  echo 'export PATH=$SCALA_HOME/bin:$PATH' > /etc/profile.d/scala.sh

RUN \
  curl -L -o sbt-$SBT_VERSION.deb http://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion

RUN mkdir -p /root/.aws/ && echo '[default]\n\
AWS_DEFAULT_REGION=ap-southeast-2\n\
region=ap-southeast-2\n\
output=json\n' >> /root/.aws/config  

WORKDIR /performance_wks
COPY build.sbt /performance_wks/
COPY run.sh /performance_wks/
COPY src /performance_wks/src
COPY project /performance_wks/project

# Some tuning on clients based on 
# http://gatling.io/docs/2.0.0-RC2/general/operations.html
# http://yandextank.readthedocs.io/en/latest/generator_tuning.html#tuning
# Following two are set at run of docker container
# sysctl -w net.ipv4.ip_local_port_range="1025 65535"
# sysctl -w net.netfilter.nf_conntrack_max=1048576
RUN echo 'session required pam_limits.so' >> /etc/pam.d/common-session-noninteractive && \
 echo 'session required pam_limits.so' >> /etc/pam.d/common-session 

# Remove any dep accidently is copied from host
# Just to make sure dependcies are preinstalled test start is faster
RUN rm -rf project/project/ project/target target && \
 sbt compile

ENTRYPOINT ["./run.sh"]
