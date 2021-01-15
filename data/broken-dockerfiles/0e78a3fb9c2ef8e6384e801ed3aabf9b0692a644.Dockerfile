FROM rocker/r-base

MAINTAINER Paolo Di Tommaso <paolo.ditommaso@gmail.com>

RUN wget -q http://dl.bintray.com/groovy/maven/apache-groovy-binary-2.4.4.zip && \
  unzip apache-groovy-binary-2.4.4.zip && \
  rm apache-groovy-binary-2.4.4.zip 

RUN apt-get update && apt-get install -y make datamash 
RUN apt-get install -y openjdk-7-jdk

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/groovy-2.4.4/bin/

RUN R -e 'install.packages("scales")' && \
    R -e 'install.packages("reshape")' && \
    R -e 'install.packages("ggplot2")' && \
    R -e 'install.packages("grid")'
