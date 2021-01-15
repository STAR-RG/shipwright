FROM openjdk:7-jdk

ENV CATALINA_OPTS -Xms512m -Xmx512m -XX:MaxPermSize=256m
ENV GRAILS_VERSION 2.2.5
ENV GRAILS_HOME /opt/grails
ENV PATH $GRAILS_HOME/bin:$PATH

WORKDIR /opt

RUN curl -s -L -o grails.zip https://github.com/grails/grails-core/releases/download/v${GRAILS_VERSION}/grails-${GRAILS_VERSION}.zip \
    && unzip -q grails.zip \
    && rm grails.zip \
    && ln -s grails-${GRAILS_VERSION} grails

WORKDIR /app

EXPOSE 8080

ADD . /app

# AfPersistence/grails-app/conf/BuildConfig.groovy hard coded AfSecurity path. So we have to make a symbol link
RUN ln -s plugins annotationframework \
    && grails compile \
    && sed -e 's/localhost:3306/db:3306/' -e 's/catch_test/catch/' Catch-config.properties > catch-config.properties

VOLUME ['/app/web-app/uploads']

CMD ["grails", "run-app"]
