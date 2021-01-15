FROM tomcat:9.0.1
LABEL maintainer="chunt" description="connects SSC to a docker mysql image*requires use of the defined configuration, or customize"

# args; expected that there be a directory named files that contains:
# 	-jdbc jar
#	-ssc.war
#	-fortify.license
#	-ssc.autoconfig (optional)
ARG MY_FILES_DIR=files
ARG TMP_DIR=/root/mytemp
ARG TOMCAT_DIR=/usr/local/tomcat
ARG FORTIFY_HOME=$TOMCAT_DIR/fortify
ARG MYSQL_JAR=mysql-connector-java-5.1.35.jar
ARG SSC_CONFIG=ssc.autoconfig

# fortify ssc home dir (log/conf locations default=/root/.fortify/ssc)
# keep it with TOMCAT_HOME in its own ssc directory struture
ENV JAVA_OPTS="$JAVA_OPTS -Dfortify.home=$FORTIFY_HOME"

# create temp dir for needed files
RUN mkdir $TMP_DIR/
COPY $MY_FILES_DIR/* $TMP_DIR/

# clear out "default" apps that tomcat includes
# put ssc war in webapps dir for deployment
# add database driver jar to tomcat lib
# (optional) add autoconfig file to ssc.home
RUN rm -rf $TOMCAT_DIR/webapps/* && \
	mkdir -p $FORTIFY_HOME/ssc/ssc_search_index && \
	mv $TMP_DIR/fortify.license $FORTIFY_HOME && \
	mv $TMP_DIR/ssc.war $TOMCAT_DIR/webapps && \
	mv $TMP_DIR/$MYSQL_JAR $TOMCAT_DIR/lib && \
	mv $TMP_DIR/$SSC_CONFIG $FORTIFY_HOME

# cleanup temp dir
RUN rm -rf $TMP_DIR

# still have to use the -p flag on run
EXPOSE 80
