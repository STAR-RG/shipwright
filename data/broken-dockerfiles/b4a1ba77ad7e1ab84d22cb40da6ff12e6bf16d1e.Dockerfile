#-------------------------------------------------------
# $VERSION: [v1.1-8] $
# $DATE:    [Wed Dec 27,2017 - 06:18:00PM -0600] $
# $AUTHOR:  [mhassan2 <mhassan@splunk.com>] $

#Increase OSX default docker size link:
#https://forums.docker.com/t/increase-docker-container-disk-space-on-os-x/26725/2
#https://github.com/docker/dceu_tutorials/blob/master/07-volumes.md

#To build (from build dir): (11-15 mins)
#time docker build --no-cache=true -f Dockerfile.datafabric -t splunknbox/splunk_datafabric .

#To run: (cached: 3sec  Download: 5 mins)
#time docker run -d --name=DF01 --hostname=DF01 -p 2122:22 -p 8000:8000 -p 8020:8020 -p 8030:8030 -p 8032:8032 -p 8088:8088 -p 9090:9090 -p 50070:50070 splunknbox/splunk_datafabric
#OR
#time docker run -d --name=DF01 --hostname=DF01 -p 2122:22 -p 8000:8000 -p 9090:9090 -p 50070:50070 splunknbox/splunk_datafabric

#Push to splunknbox repo on docker hub: (~115 mins)
#time docker push splunknbox/splunk_datafabric
#-------------------------------------------------------

#--------COLORES ESCAPE CODES------------
#for i in `seq 1 100`; do printf "\033[48;5;${i}m${i} "; done
#NC='\033[0m' # No Color
#Black="\033[0;30m";             White="\033[1;37m"
#Red="\033[0;31m";               LightRed="\033[1;31m"
#Green="\033[0;32m";             LightGreen="\033[1;32m"
#BrownOrange="\033[0;33m";       Yellow="\033[1;33m"
#Blue="\033[0;34m";              LightBlue="\033[1;34m"
#Purple="\033[0;35m";            LightPurple="\033[1;35m"
#Cyan="\033[0;36m";              LightCyan="\033[1;36m"
#LightGray="\033[0;37m";         DarkGray="\033[1;30m"
#BlackOnGreen="\033[30;48;5;82m"
#WhiteOnBurg="\033[30;48;5;88m"
#
#BoldWhiteOnRed="\033[1;1;5;41m"
#BoldWhiteOnGreen="\033[1;1;5;42m"
#BoldWhiteOnYellow="\033[1;1;5;43m"
#BoldWhiteOnBlue="\033[1;1;5;44m"
#BoldWhiteOnPink="\033[1;1;5;45m"
#BoldWhiteOnTurquoise="\033[1;1;5;46m"

#BoldYellowOnBlue="\033[1;33;44m"
#BoldYellowOnPurple="\033[1;33;44m"

#LABEL com.splunk.version="0.3-beta"
#LABEL vendor="Splunk>"
#LABEL com.splunk.release-date="2017-02-12"
#LABEL com.splunk.version.is-production=""


FROM debian:jessie
ENV GIT_VERSION="$VERSION: [v1.1-8] $"
ENV CONTAINER_VER 1.0
MAINTAINER mhassan@splunk.com version: $CONTAINER_VER
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

#ENV SPLUNK_VERSION="6.4.3" SPLUNK_BUILD="b03109c2bad4"
#ENV SPLUNK_VERSION="6.4.4" SPLUNK_BUILD="b53a5c14bb5e"
#ENV SPLUNK_VERSION="6.5.0" SPLUNK_BUILD="59c8927def0f"
#ENV SPLUNK_VERSION="6.5.1" SPLUNK_BUILD="f74036626f0c"
#ENV SPLUNK_VERSION="6.5.2" SPLUNK_BUILD="67571ef4b87d"
#ENV SPLUNK_VERSION="6.5.3" SPLUNK_BUILD="36937ad027d4"
#ENV SPLUNK_VERSION="6.5.4" SPLUNK_BUILD="adb84211dd7c"
#ENV SPLUNK_VERSION="6.5.5" SPLUNK_BUILD="586c3ec08cfb"
#ENV SPLUNK_VERSION="6.6.0" SPLUNK_BUILD="1c4f3bbe1aea"
#ENV SPLUNK_VERSION="6.6.1" SPLUNK_BUILD="aeae3fe0c5af"
#ENV SPLUNK_VERSION="6.6.2" SPLUNK_BUILD="4b804538c686"
#ENV SPLUNK_VERSION="6.6.3" SPLUNK_BUILD="e21ee54bc796"
#ENV SPLUNK_VERSION="7.0.0" SPLUNK_BUILD="c8a78efdd40f"
ENV SPLUNK_VERSION="7.0.1"  SPLUNK_BUILD="2b5b15c4ee89"

ENV SPLUNK_PRODUCT splunk
ENV SPLUNK_FILENAME splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz
ENV SPLUNK_HOME /opt/splunk
ENV SPLUNK_GROUP splunk
ENV SPLUNK_USER splunk
ENV SPLUNK_BACKUP_DEFAULT_ETC /var/opt/splunk


RUN printf "\033[1;33m\n\n-------------------- Installing Misc Stuff ---------------------\n"
RUN apt-get -qq update && printf "\033[1;33m"
RUN apt-get -qq install -y apt-utils lsb-release curl && apt-get update && printf "\033[1;33m"
#RUN apt-get -qq update && printf "\033[1;33m"
RUN apt-get -qq install -y wget sudo vim net-tools telnet dnsutils && apt-get -qq update
COPY configs/containers.bashrc /root/.bashrc
COPY configs/containers.vimrc /root/.vimrc
COPY configs/environment /etc

RUN printf "\033[1;32m\n\n-------------------- Installing Splunk ---------------------\n"
# add splunk:splunk user
RUN groupadd -r ${SPLUNK_GROUP} \
    && useradd -r -m -g ${SPLUNK_GROUP} ${SPLUNK_USER}
# make the "en_US.UTF-8" locale so splunk will be utf-8 enabled by default
RUN apt-get -qq install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# pdfgen dependency
RUN apt-get -qq install -y libgssapi-krb5-2
RUN apt-get -qq update && printf "\033[1;32m"

# Download official Splunk release, verify checksum and unzip in /opt/splunk
# Also backup etc folder, so it will be later copied to the linked volume
RUN mkdir -p ${SPLUNK_HOME} \
    && wget -qO /tmp/${SPLUNK_FILENAME} https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME} \
    && wget -qO /tmp/${SPLUNK_FILENAME}.md5 https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}.md5 \
    && (cd /tmp && md5sum -c ${SPLUNK_FILENAME}.md5) \
    && tar -xzf /tmp/${SPLUNK_FILENAME} --strip 1 -C ${SPLUNK_HOME} \
    && rm /tmp/${SPLUNK_FILENAME} \
    && rm /tmp/${SPLUNK_FILENAME}.md5 \
    && mkdir -p /var/opt/splunk \
    && cp -R ${SPLUNK_HOME}/etc ${SPLUNK_BACKUP_DEFAULT_ETC} \
    && rm -fR ${SPLUNK_HOME}/etc \
    && chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} ${SPLUNK_HOME} \
    && chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} ${SPLUNK_BACKUP_DEFAULT_ETC} \
    && rm -rf /var/lib/apt/lists/*
#    && apt-get purge -y --auto-remove wget \
COPY scripts/splunk_web_conf.sh /sbin/splunk_web_conf.sh
RUN chmod +x /sbin/splunk_web_conf.sh
COPY scripts/splunk_first_run.sh /sbin/splunk_first_run.sh
RUN chmod +x /sbin/splunk_first_run.sh
COPY scripts/splunk /etc/init.d
RUN chmod +x /etc/init.d/splunk
#--------------------------------------------------------------

RUN printf "\033[1;32m\n\n-------------------- Downloading WORLD database ---------------------\n"
RUN wget -qO /tmp/world.sql.gz http://downloads.mysql.com/docs/world.sql.gz
#COPY Packages_download/world.sql.gz  /tmp
#COPY scripts/startup_mysql.sh /sbin/startup_mysql.sh
#RUN chmod +x /sbin/startup_mysql.sh
RUN gunzip /tmp/world.sql.gz
#--------------------------------------------------------------

RUN printf "\033[1;34m\n\n-------------------- Installing MySQL ---------------------\n"
RUN apt-get -qq update && printf "\033[1;34m"
RUN apt-get -qq install -y mysql-server
#copy the customized mysql startup script
COPY scripts/mysql /etc/init.d/mysql
RUN chmod +x /etc/init.d/mysql
#--------------------------------------------------------------


RUN printf "\033[1;36m\n\n-------------------- Installing supervisord ---------------------\n"
RUN apt-get -qq update && printf "\033[1;36m"
RUN apt-get -qq install -y supervisor
COPY configs/supervisord.conf /etc/supervisor/supervisord.conf
#configure built-in webserver
#RUN mkdir -p /etc/nginx/sites-available/
#RUN mkdir -p /etc/nginx/sites-enable/
#COPY configs/supervisord.web /etc/nginx/sites-available/supervisord
#RUN  ln -s /etc/nginx/sites-available/supervisord /etc/nginx/sites-enable/supervisord
#--------------------------------------------------------------


#http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html
RUN printf "\033[1;33m\n\n-------------------- Installing Java 8 ---------------------\n"
#RUN apt-get update	&& apt-get install -y software-properties-common && apt-get update
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN printf "\033[1;33m"
RUN apt-get -qq update && printf "\033[1;33"
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-get -qq install -y oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
#--------------------------------------------------------------

RUN printf "\033[1;32m\n\n-------------------- Installing splunk apps: DBconnect, MySQL driver & Kafka add-on ---------------------\n"
#order of splunk apps install is important. First DBconnet then the MySQL driver
#DBconnect App 3.11
COPY splunk_apps/splunk-db-connect_311.tgz /tmp/splunk-db-connect_311.tgz
RUN tar -zxf /tmp/splunk-db-connect_311.tgz -C /var/opt/splunk/etc/apps
RUN rm -f /tmp/splunk-db-connect_311.tgz

#MySQL java driver
RUN wget -qO /tmp/mysql-connector-java-5.1.44.tar.gz https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.44.tar.gz
#COPY Packages_download/mysql-connector-java-5.1.44.tar.gz  /tmp
RUN	tar -zxf /tmp/mysql-connector-java-5.1.44.tar.gz -C /var/opt/splunk/etc/apps/splunk_app_db_connect/drivers/
RUN rm -f /tmp/mysql-connector-java-5.1.44.tar.gz

#Kafka add-on
#COPY splunk_apps/splunk-add-on-for-kafka_110.tgz /tmp/splunk-add-on-for-kafka_110.tgz
#RUN tar -zxf /tmp/splunk-add-on-for-kafka_110.tgz -C /var/opt/splunk/etc/apps
#RUN rm -f /tmp/splunk-add-on-for-kafka_110.tgz

#Kafka connect app (beta)
#COPY splunk_apps/kafka-connect-splunk.tar.gz /tmp
#RUN tar -zxf /tmp/kafka-connect-splunk.tar.gz -C /var/opt/splunk/etc/apps
#RUN rm -f /tmp/kafka-connect-splunk.tar.gz

#Configuring indexers [include hadoop vidx]
COPY splunk_apps/indexes.tgz /tmp/indexes.tgz
RUN tar xzf /tmp/indexes.tgz -C /opt/splunk
#Install Splunk apps [dbconnect 2.x, kafka addon,] & dashboards [search app]
COPY splunk_apps/apps_configs.tgz /tmp/apps_configs.tgz
RUN tar xzf /tmp/apps_configs.tgz -C /var/opt/splunk/etc/apps/
RUN mkdir -p /var/opt/splunk/etc/apps/user-prefs/local
COPY configs/user-prefs.conf  /var/opt/splunk/etc/apps/user-prefs/local
RUN chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} /var/opt/splunk/etc/apps
RUN rm -f /tmp/indexes.tgz /tmp/apps_configs.tgz
#--------------------------------------------------------------

RUN printf "\033[1;36m\n\n-------------------- Installing & Configuring sshd ---------------------\n"
RUN apt-get -qq install -y openssh-server rsync
RUN apt-get -qq update && printf "\033[1;36m"

#passwordless ssh login
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys
RUN echo  "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo  "UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
#RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config
RUN echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config
#Share static host keys so we dont get ssh warning with different builds
COPY configs/ssh_host_keys.tgz /tmp/ssh_host_keys.tgz
RUN tar -zxf /tmp/ssh_host_keys.tgz -C /etc/ssh

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo root:splunk123 | chpasswd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN rm -f /tmp/ssh_host_keys.tgz
COPY scripts/ssh /etc/init.d/
RUN chmod +x /etc/init.d/ssh
#--------------------------------------------------------------

RUN printf "\033[1;37m\n\n-------------------- Installing Hadoop(Yarn) ---------------------\n"
#force hadoop to use different ssh port
#ENV HADOOP_SSH_OPTS "-p 2122"
#Make the default user "splunk" that write to hdfs to address the permission issue
ENV HADOOP_USER_NAME="splunk"

#Download sample hadoop data
RUN wget -qO /tmp/Hunkdata.json.gz http://www.splunk.com/web_assets/hunk/Hunkdata.json.gz
#COPY Packages_download/Hunkdata.json.gz /tmp
COPY /data/avro_07_31_2017.avro /tmp/avro_07_31_2017.avro
COPY /data/avro_08_01_2017.avro /tmp/avro_08_01_2017.avro

RUN wget -qO /tmp/hadoop-2.9.0.tar.gz http://apache.claz.org/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz
#COPY Packages_download/hadoop-2.9.0.tar.gz /tmp
RUN tar -zxf /tmp/hadoop-2.9.0.tar.gz -C /opt
RUN rm -f /tmp/hadoop-2.9.0.tar.gz

#Customization
RUN mkdir -p /opt/hadoop-2.9.0/etc/input
RUN cp /opt/hadoop-2.9.0/etc/hadoop/*.xml /opt/hadoop-2.9.0/etc/input/
#RUN /bin/bash -c "/opt/hadoop-2.9.0/bin/hadoop jar /opt/hadoop-2.9.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.9.0.jar grep input output 'dfs[a-z.]+'"
COPY configs/core-site.xml /opt/hadoop-2.9.0/etc/hadoop/core-site.xml
COPY configs/hdfs-site.xml /opt/hadoop-2.9.0/etc/hadoop/hdfs-site.xml
COPY configs/mapred-site.xml /opt/hadoop-2.9.0/etc/hadoop/mapred-site.xml
COPY configs/yarn-site.xml /opt/hadoop-2.9.0/etc/hadoop/yarn-site.xml
#Format HDFS
RUN /opt/hadoop-2.9.0/bin/hdfs namenode -format -force
#RUN printf "\033[0;36m"
#COPY scripts/startup_hadoop.sh /sbin/startup_hadoop.sh
#RUN chmod +x /sbin/startup_hadoop.sh
COPY scripts/hadoop /etc/init.d/
COPY scripts/yarn /etc/init.d/
COPY scripts/start-yarn.sh /opt/hadoop-2.9.0/sbin/
COPY scripts/stop-yarn.sh /opt/hadoop-2.9.0/sbin/
COPY scripts/start-dfs.sh /opt/hadoop-2.9.0/sbin/
COPY scripts/stop-dfs.sh /opt/hadoop-2.9.0/sbin/

RUN chmod +x /etc/init.d/hadoop
RUN chmod +x /etc/init.d/yarn
RUN chmod +x /opt/hadoop-2.9.0/sbin/start-yarn.sh
RUN chmod +x /opt/hadoop-2.9.0/sbin/stop-yarn.sh
RUN chmod +x /opt/hadoop-2.9.0/sbin/start-dfs.sh
RUN chmod +x /opt/hadoop-2.9.0/sbin/stop-dfs.sh
#--------------------------------------------------------------

#>>>>>> disable Zookeeper install. It is embemded in Kafka install <<<<<<
#https://www.tutorialspoint.com/apache_kafka/apache_kafka_basic_operations.htm
#RUN printf "\033[1;36m\n\n-------------------- Installing ZooKeeper ---------------------\n"
#RUN wget -qO /tmp/zookeeper-3.4.11.tar.gz  http://apache.claz.org/zookeeper/zookeeper-3.4.11/zookeeper-3.4.11.tar.gz
#COPY Packages_download/zookeeper-3.4.11.tar.gz  /tmp
#RUN tar -zxf /tmp/zookeeper-3.4.11.tar.gz -C /opt
#RUN rm -f /tmp/zookeeper-3.4.11.tar.gz
#Customization
#COPY configs/zoo.cfg /opt/zookeeper-3.4.11/conf/zoo.cfg
#--------------------------------------------------------------
#>>>>>> disable Zookeeper install. It is embemded in Kafka install <<<<<<

RUN printf "\033[1;33m\n\n-------------------- Installing Kafka ---------------------\n"
RUN wget -qO  /tmp/kafka_2.11-1.0.0.tgz http://apache.claz.org/kafka/1.0.0/kafka_2.11-1.0.0.tgz
#COPY Packages_download/kafka_2.11-1.0.0.tgz /tmp
RUN tar -zxf /tmp/kafka_2.11-1.0.0.tgz -C /opt
RUN rm -f /tmp/kafka_2.11-1.0.0.tgz

COPY data/sample_kafka.log /tmp/sample_kafka.log
#COPY scripts/startup_zoo_kafka.sh /sbin/startup_zoo_kafka.sh
#RUN chmod +x /sbin/startup_zoo_kafka.sh
COPY scripts/zookeeper-server-start.sh /opt/kafka_2.11-1.0.0/bin
COPY scripts/zookeeper-server-stop.sh /opt/kafka_2.11-1.0.0/bin
COPY scripts/kafka-server-stop.sh /opt/kafka_2.11-1.0.0/bin
COPY scripts/kafka-server-start.sh /opt/kafka_2.11-1.0.0/bin
COPY scripts/kafka /etc/init.d/
COPY scripts/zookeeper /etc/init.d/
RUN chmod +x /etc/init.d/kafka
RUN chmod +x /etc/init.d/zookeeper
RUN chmod +x /opt/kafka_2.11-1.0.0/bin/zookeeper-server-start.sh
RUN chmod +x /opt/kafka_2.11-1.0.0/bin/zookeeper-server-stop.sh
RUN chmod +x /opt/kafka_2.11-1.0.0/bin/kafka-server-stop.sh
RUN chmod +x /opt/kafka_2.11-1.0.0/bin/kafka-server-start.sh
#--------------------------------------------------------------

RUN printf "\033[1;34m\n\n-------------------- Installing Apache NIFI ---------------------\n"
RUN wget -qO /tmp/nifi-1.4.0-bin.tar.gz http://apache.claz.org/nifi/1.4.0/nifi-1.4.0-bin.tar.gz
#COPY Packages_download/nifi-1.4.0-bin.tar.gz /tmp
RUN tar -xzf /tmp/nifi-1.4.0-bin.tar.gz -C /opt
RUN rm -f /tmp/nifi-1.4.0-bin.tar.gz

#need uuidgen command for nifi UI configuration
#RUN apt-get -qq install -y uuid-runtime

#create nifi data directory with sample access combined logs
RUN mkdir /opt/nifi-1.4.0/splunk_sample_data
COPY data/access.log /opt/nifi-1.4.0/splunk_sample_data/access1.log
COPY data/access.log /opt/nifi-1.4.0/splunk_sample_data/access2.log
COPY data/access.log /opt/nifi-1.4.0/splunk_sample_data/access3.log
COPY configs/flow.xml.gz /opt/nifi-1.4.0/conf
#COPY scripts/startup_nifi.sh /sbin/startup_nifi.sh
#RUN chmod +x /sbin/startup_nifi.sh
COPY scripts/nifi /etc/init.d/
COPY scripts/nifi.sh   /opt/nifi-1.4.0/bin/
RUN chmod +x /etc/init.d/nifi
RUN chmod +x /opt/nifi-1.4.0/bin/nifi.sh

#nifi customization
RUN echo "java=/usr/lib/jvm/java-8-oracle/" >> /opt/nifi-1.4.0/conf/bootstrap
RUN echo "" >> /opt/nifi-1.4.0/bin/nifi-env.sh
#this template will be manually imported in the UI (file is loaded from local disk)
COPY configs/Splunk_HEC_TCP_RESTQuery.xml /tmp/Splunk_HEC_TCP_RESTQuery.xml
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle/" >> /opt/nifi-1.4.0/bin/nifi-env.sh
#change default nifi port to 9090
RUN sed -i 's/nifi.web.http.port=8080/nifi.web.http.port=9090/' /opt/nifi-1.4.0/conf/nifi.properties
#--------------------------------------------------------------


#clean up /tmp
RUN printf "\033[1;37m\n\n-------------------- /tmp cleanup ---------------------\n"
#	/tmp/Hunkdata.json.gz /tmp/world.sql  dont remove now. will be used with startup scripts later

#COPY configs/local.tar /tmp
#RUN tar -xvf /tmp/local.tar /opt/splunk/etc/apps/splunk_app_db_connect/local/

#startup scripts with be kicked off from supervisord.conf


# Ports Splunk Web, Splunk Daemon, KVStore, Splunk Indexing Port, Network Input, HTTP Event Collector
EXPOSE 8000/tcp 8089/tcp 8191/tcp 9997/tcp 1514/udp 8088/tcp 9088/tcp
#MySQL
EXPOSE 3306/tcp
#supervisord web
EXPOSE 9001/tcp
#Hadoop: Resource mgr:8088  namednode:50070  hdfs:9000
EXPOSE 50070/tcp 9000/tcp 8088/tcp 2122/tcp
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088 10020 19888 10200
#Other ports
EXPOSE 49707 2122
#NIFI
EXPOSE 9090

WORKDIR /opt/splunk

# Configurations folder, var folder for everything (indexes, logs, kvstore)
VOLUME [ "/opt/splunk/etc", "/opt/splunk/var", "/var/lib/mysql" ]

CMD ["/usr/bin/supervisord"]


RUN printf "\033[1;33m\n\n-------------------- We are done baby! ---------------------\033[0m\n"


