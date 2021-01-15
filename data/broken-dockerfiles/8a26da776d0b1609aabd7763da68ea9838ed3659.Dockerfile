FROM java:8-jre
MAINTAINER Justin Payne justin.payne@fda.hhs.gov

RUN apt-get UPDATE -y && apt-get install -y \
    maven \
    && apt-get clean

