#######################################################################
# Creates a base Centos 6.7 image with JBoss EAP-6.4.x                #
#######################################################################

# Use the centos 6.7 base image
FROM centos:6.7

MAINTAINER fbascheper <temp01@fam-scheper.nl>

# Update the system
RUN yum -y update;yum clean all

##########################################################
# Install Java JDK
##########################################################
RUN yum -y install wget && \
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-linux-x64.rpm && \
    echo "1e587aca2514a612b10935813b1cef28  jdk-8u65-linux-x64.rpm" >> MD5SUM && \
    md5sum -c MD5SUM && \
    rpm -Uvh jdk-8u65-linux-x64.rpm && \
    yum -y remove wget && \
    rm -f jdk-8u65-linux-x64.rpm MD5SUM

ENV JAVA_HOME /usr/java/jdk1.8.0_65

# Perform the "Yes, I want grownup encryption" Java ceremony
RUN mkdir -p /tmp/UnlimitedJCEPolicy
ADD ./jce-unlimited/US_export_policy.jar /tmp/UnlimitedJCEPolicy/US_export_policy.jar
ADD ./jce-unlimited/local_policy.jar     /tmp/UnlimitedJCEPolicy/local_policy.jar
RUN mv /tmp/UnlimitedJCEPolicy/*.*       $JAVA_HOME/jre/lib/security/
RUN rm -rf /tmp/UnlimitedJCEPolicy*

# Add CA certs
ADD ./trusted-root-ca/StaatderNederlandenRootCA-G2.pem     /tmp/StaatderNederlandenRootCA-G2.pem
RUN $JAVA_HOME/bin/keytool -import -noprompt -trustcacerts -alias StaatderNederlandenRootCA-G2 -file  /tmp/StaatderNederlandenRootCA-G2.pem -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit


##########################################################
# Create jboss user
##########################################################

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r jboss && useradd -r -g jboss -m -d /home/jboss jboss


############################################
# Install EAP 6.4.0.GA
############################################
RUN yum -y install zip unzip

USER jboss
ENV INSTALLDIR /home/jboss/EAP-6.4.0
ENV HOME /home/jboss

RUN mkdir $INSTALLDIR && \
   mkdir $INSTALLDIR/distribution && \
   mkdir $INSTALLDIR/resources


USER root
ADD distribution $INSTALLDIR/distribution
ADD distribution-patches $INSTALLDIR/distribution-patches
RUN chown -R jboss:jboss /home/jboss
RUN find /home/jboss -type d -execdir chmod 770 {} \;
RUN find /home/jboss -type f -execdir chmod 660 {} \;

USER jboss
RUN unzip $INSTALLDIR/distribution/jboss-eap-6.4.0.zip  -d $INSTALLDIR

# Add patch - EAP 6.4.5
RUN $INSTALLDIR/jboss-eap-6.4/bin/jboss-cli.sh "patch apply $INSTALLDIR/distribution/jboss-eap-6.4.5-patch.zip"

# ---------------------------------------------------------------------------------
# JSF 2.1 API patch
# See https://github.com/fbascheper/JBoss-EAP6-patch-01477141
# ---------------------------------------------------------------------------------
# Add oneoff patch - EBS-01477141-v2.patch
RUN $INSTALLDIR/jboss-eap-6.4/bin/jboss-cli.sh "patch apply $INSTALLDIR/distribution-patches/EBS-01477141-v2.patch.zip --override-all"


############################################
# Create start script to run EAP instance
############################################
USER root

RUN yum -y install curl
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64" \
    	&& chmod +x /usr/local/bin/gosu


############################################
# Remove install artifacts
############################################
RUN rm -rf $INSTALLDIR/distribution
RUN rm -rf $INSTALLDIR/distribution-patches
RUN rm -rf $INSTALLDIR/resources

############################################
# Add customization sub-directories (for entrypoint)
############################################
ADD docker-entrypoint-initdb.d  /docker-entrypoint-initdb.d
RUN chown -R jboss:jboss        /docker-entrypoint-initdb.d
RUN find /docker-entrypoint-initdb.d -type d -execdir chmod 770 {} \;
RUN find /docker-entrypoint-initdb.d -type f -execdir chmod 660 {} \;

ADD modules  $INSTALLDIR/modules
RUN chown -R jboss:jboss $INSTALLDIR/modules
RUN find $INSTALLDIR/modules -type d -execdir chmod 770 {} \;
RUN find $INSTALLDIR/modules -type f -execdir chmod 660 {} \;

############################################
# Expose paths and start JBoss
############################################

EXPOSE 22 5455 9999 8009 8080 8443 3528 3529 7500 45700 7600 57600 5445 23364 5432 8090 4447 4712 4713 9990 8787

RUN mkdir /etc/jboss-as
RUN mkdir /var/log/jboss/
RUN chown jboss:jboss /var/log/jboss/

COPY docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh

############################################
# Start JBoss in stand-alone mode
############################################

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["start-jboss"]
