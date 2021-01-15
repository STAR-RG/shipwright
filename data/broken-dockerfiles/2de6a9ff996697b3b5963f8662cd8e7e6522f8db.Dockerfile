FROM ubuntu:17.10

ENV HADOOP_HOME /opt/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update
RUN apt-get install -y --reinstall build-essential
RUN apt-get install -y ssh 
RUN apt-get install -y rsync 
RUN apt-get install -y vim 
RUN apt-get install -y net-tools
RUN apt-get install -y openjdk-8-jdk 
RUN apt-get install -y python2.7-dev 
RUN apt-get install -y libxml2-dev 
RUN apt-get install -y libkrb5-dev 
RUN apt-get install -y libffi-dev 
RUN apt-get install -y libssl-dev 
RUN apt-get install -y libldap2-dev 
RUN apt-get install -y python-lxml 
RUN apt-get install -y libxslt1-dev 
RUN apt-get install -y libgmp3-dev 
RUN apt-get install -y libsasl2-dev 
RUN apt-get install -y libsqlite3-dev  
RUN apt-get install -y libmysqlclient-dev

RUN \
    if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python2.7 /usr/bin/python; fi

# If you have already downloaded the tgz, add this line OR comment it AND ...
ADD hadoop-3.1.0.tar.gz /

# ... uncomment the 2 first lines
RUN \
#    wget http://apache.crihan.fr/dist/hadoop/common/hadoop-3.1.0/hadoop-3.1.0.tar.gz && \
#    tar -xzf hadoop-3.1.0.tar.gz && \
    mv hadoop-3.1.0 $HADOOP_HOME && \
    for user in hadoop hdfs yarn mapred hue; do \
         useradd -U -M -d /opt/hadoop/ --shell /bin/bash ${user}; \
    done && \
    for user in root hdfs yarn mapred hue; do \
         usermod -G hadoop ${user}; \
    done && \
    echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
#    echo "export HDFS_DATANODE_SECURE_USER=hdfs" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

####################################################################################
# HUE

# https://www.dropbox.com/s/auwpqygqgdvu1wj/hue-4.1.0.tgz
ADD hue-4.1.0.tgz /


##
RUN mv -f /hue-4.1.0 /opt/hue
WORKDIR /opt/hue
RUN make apps

RUN chown -R hue:hue /opt/hue

WORKDIR /


####################################################################################

RUN \
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

ADD *xml $HADOOP_HOME/etc/hadoop/

ADD ssh_config /root/.ssh/config

ADD hue.ini /opt/hue/desktop/conf

ADD start-all.sh start-all.sh

EXPOSE 8088 9870 9864 19888 8042 8888

CMD bash start-all.sh
