# This is a Dockerfile for creating a PcapOptikon Container from the latest
# Ubuntu base image. This is known bo be working on Ubuntu 14.04. It should work on any later version
# This is a full installation of PcapOptikon including all the dependencies and Suricata.
# The container will run Oinkmaster every 24 hours to update the Emergint Threats Open ruleset.
FROM ubuntu:14.04
MAINTAINER p.delsante@certego.net
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
EXPOSE 8000

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install \
            cpanminus \
            expect \
            git \
            libmysqlclient-dev \
            libssl-dev \
            mysql-common \
            mysql-client \
            mysql-server \
            oinkmaster \
            python-dev \
            python-mysqldb \
            python-software-properties \
            python-pip \
            software-properties-common
        
RUN add-apt-repository -y ppa:oisf/suricata-stable && apt-get update && apt-get -y install suricata

RUN sed -ir '/^# more information.$/ a\
url = http://rules.emergingthreats.net/open/suricata/emerging.rules.tar.gz' /etc/oinkmaster.conf

RUN sed -ir 's|^classification-file: /etc/suricata/classification.config$|classification-file: /etc/suricata/rules/classification.config|' /etc/suricata/suricata.yaml
RUN sed -ir 's|^reference-file: /etc/suricata/reference.config$|reference-file: /etc/suricata/rules/reference.config|' /etc/suricata/suricata.yaml
RUN sed -ir 's|#- rule-reload: true|- rule-reload: true|' /etc/suricata/suricata.yaml
RUN sed -ir 's|^  checksum-valdation: yes|  checksum-valdation: no|' /etc/suricata/suricata.yaml
RUN sed -ir 's|^  checksum-checks: auto|  checksum-checks: no|' /etc/suricata/suricata.yaml
RUN touch /etc/suricata/threshold.config
RUN mkdir -p /opt/pcapoptikon
        
ADD requirements.txt /opt/pcapoptikon/requirements.txt
RUN pip install -r /opt/pcapoptikon/requirements.txt
        
ADD . /opt/pcapoptikon

RUN service mysql start && \
        mysqladmin create pcapoptikon && \
        cd /opt/pcapoptikon/ && \
        python manage.py migrate --noinput && \
        echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell
        
VOLUME ["/var/lib/mysql"]

CMD ["/opt/pcapoptikon/start.sh"]
