# DEPLOYMENT INSTRUCTIONS

# To build the image, refer:
# docker build -t egs_shim .

# To run using the container, refer the following command:
# docker run --privileged -it -d \
#		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
#		-p 9000:9000 -p 9001:80 egs_shim

# this port should be same as one configured for the shim
###########################################################

FROM centos
MAINTAINER arcolife <archit.py@gmail.com>

# Install useful packages
RUN yum install -y procps-ng tar vim git wget gcc

RUN wget https://www.softwarecollections.org/en/scls/rhscl/python33/epel-7-x86_64/download/rhscl-python33-epel-7-x86_64.noarch.rpm
RUN yum clean all; yum install -y rhscl-python33-epel-7-x86_64.noarch.rpm; yum -y install python33

RUN yum install -y mod_wsgi httpd

# Clone the shim
# RUN git clone https://github.com/distributed-system-analysis/es-graphite-shim.git /opt/es-graphite-shim

RUN mkdir -p /opt/es-graphite-shim/es-graphite-shim/
ADD es-graphite-shim/ /opt/es-graphite-shim/es-graphite-shim/
RUN mkdir /opt/es-graphite-shim/logs/; touch /opt/es-graphite-shim/logs/error.log; touch /opt/es-graphite-shim/logs/access.log
COPY requirements.txt /opt/es-graphite-shim/
COPY conf/local_settings.py /opt/es-graphite-shim/es-graphite-shim/

WORKDIR /opt/es-graphite-shim

# RUN easy_install pip
# RUN virtualenv venv
# RUN source venv/bin/activate; pip install -r /opt/es-graphite-shim/requirements.txt
RUN scl enable python33 "easy_install-3.3 pip"

# RUN scl enable python33 "pip3.3 install virtualenv"
# RUN scl enable python33 "virtualenv venv; source venv/bin/activate; pip3.3 install -r /opt/es-graphite-shim/requirements.txt; bash"
RUN scl enable python33 "pip3.3 install -r /opt/es-graphite-shim/requirements.txt"

# add httpd configs
COPY conf/graphite_shim.conf.example /etc/httpd/conf.d/graphite_shim.conf
RUN sed -i s#Listen\ 80#Listen\ 80\\nListen\ 9000#g /etc/httpd/conf/httpd.conf

# modify selinux policies and folder ownerships
RUN chown -R apache:apache /opt/es-graphite-shim/

# Enable using systemd
RUN scl enable python33 bash; systemctl enable httpd

RUN echo "root:egs_shim" | chpasswd

# Launch bash as the default command if none specified.
CMD ["/usr/sbin/init"]
