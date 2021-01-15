FROM java:8

MAINTAINER Baptiste Mathus <batmat@batmat.net>

RUN curl http://apache.crihan.fr/dist/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz | tar xvz

ENV PATH /apache-maven-3.3.3/bin:$PATH

RUN apt-get update -y && \
    apt-get install nginx -y

ADD . /jenkins-guide-complet

WORKDIR /jenkins-guide-complet
RUN mvn clean package -Pfrench

# TODO : volume or bind-mount for Maven cache to speed up build by reusing /root/.m2/repository?

RUN mv website.html /var/www/html/index.html
RUN mv hudsonbook-html/target/html /var/www/html/html
RUN mv hudsonbook-pdf/target/book.pdf /var/www/html/continuous-integration-with-hudson.pdf

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
