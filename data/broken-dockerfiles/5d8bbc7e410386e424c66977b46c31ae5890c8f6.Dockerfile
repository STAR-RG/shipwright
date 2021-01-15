FROM simonjupp/java-mongo-tomcat
MAINTAINER Simon Jupp <simon.jupp@gmail.com>

# install some pre-reqs
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget pwgen ca-certificates curl maven git && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/EBISPOT/webpopulous.git && \
    cd webpopulous && \
    mvn clean package && \
    cp webulous-mvc/target/webulous-boot.war $CATALINA_HOME/webapps/webulous.war
