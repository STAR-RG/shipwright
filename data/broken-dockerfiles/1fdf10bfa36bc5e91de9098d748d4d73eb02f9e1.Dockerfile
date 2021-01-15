# Hortonworks Hadoop
#
# VERSION 1.2.0.1.3.0.0-107-0.0.1
FROM fkautz/java6-jre
MAINTAINER Frederick F. Kautz IV "fkautz@alumni.cmu.edu"

ADD hadoop /opt/hadoop
ADD start-hadoop.sh /start-hadoop.sh
ADD job.sh /job.sh
RUN chmod +x /start-hadoop.sh
RUN chmod +x /job.sh

# namenode 50070
# datanode 50075
# SNN 50090
# checkpoint 50105
# jobtracker 50030
# tasktracker 50060

# EXPOSE 50070 50075 50090 50105 50030 50060
CMD ["/bin/sh", "/start-hadoop.sh"]
