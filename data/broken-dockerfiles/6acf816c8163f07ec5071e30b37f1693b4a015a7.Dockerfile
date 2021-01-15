FROM oraclelinux:6.8
MAINTAINER Jose Legido "jose@legido.com"

ARG ORACLE_USER
ARG ORACLE_PASSWORD

# USUARIS
RUN groupadd -g 1001 weblogic && useradd -u 1001 -g weblogic weblogic
RUN mkdir -p /u01/install && mkdir -p /u01/scripts

# EINES
RUN yum install -y tar

COPY scrics/install_weblogic1036.sh /u01/install/install_weblogic1036.sh
COPY scrics/template1036.jar /u01/install/template1036.jar
COPY scrics/create_domain.ini /u01/install/create_domain.ini
COPY scrics/start_AdminServer.sh /u01/scripts/start_AdminServer.sh
COPY scrics/start_nodemanager.sh /u01/scripts/start_nodemanager.sh
COPY scrics/start_ALL.sh /u01/scripts/start_ALL.sh
ADD https://raw.githubusercontent.com/iwanttobefreak/weblogic/master/scrics/install/create_domain.sh /u01/install/create_domain.sh
ADD https://raw.githubusercontent.com/iwanttobefreak/weblogic/master/scrics/install/create_domain.py /u01/install/create_domain.py 
RUN chown -R weblogic. /u01
RUN chmod +x /u01/install/install_weblogic1036.sh
RUN chmod +x /u01/install/create_domain.sh
RUN chmod +x /u01/scripts/start_nodemanager.sh
RUN chmod +x /u01/scripts/start_AdminServer.sh
RUN chmod +x /u01/scripts/start_ALL.sh

USER weblogic

ENV USER_MEM_ARGS="-Djava.security.egd=file:/dev/./urandom"

RUN cd /u01/install && /u01/install/install_weblogic1036.sh $ORACLE_USER $ORACLE_PASSWORD

RUN cd /u01/install && /u01/scripts/start_AdminServer.sh && ./create_domain.sh create_domain.ini /u01/middleware1036/wlserver_10.3/server/bin/setWLSEnv.sh

#Esborrem programari d'instalacio
RUN rm -f /u01/install/*

CMD ["/u01/scripts/start_ALL.sh"]
