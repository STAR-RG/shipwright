FROM mlist/grails:2.5.3
MAINTAINER Markus List <mlist@mpi-inf.mpg.de>

# Create App Directory
COPY . /app
WORKDIR /app

# Setup Grails paths
ENV GRAILS_HOME /usr/lib/jvm/grails
ENV PATH $GRAILS_HOME/bin:$PATH

# Setup Java paths
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Compile grails app
RUN grails refresh-dependencies; grails compile

# Expose port to outside world
EXPOSE 8080
EXPOSE 41951-41960 #For printing barcode labels with DYMO

# Start grails app
ENTRYPOINT ["/sbin/my_init", "grails"]
CMD ["prod", "run-war"]
