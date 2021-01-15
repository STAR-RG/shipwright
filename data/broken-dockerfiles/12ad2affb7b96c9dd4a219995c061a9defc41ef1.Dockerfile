# VERSION 0.1

FROM ubuntu:12.10

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

RUN apt-get update
RUN apt-get upgrade

RUN apt-get install -y python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose
RUN apt-get install -y python-setuptools
RUN easy_install pip
RUN pip install requests

RUN apt-get install -y openssh-server supervisor
ADD sshd.conf /etc/supervisor/conf.d/sshd.conf
RUN mkdir -p /var/run/sshd
RUN echo root:krop | chpasswd
EXPOSE 22

# the following command works when running docker as a daemon, but it doesn't when running docker interactively:
CMD /usr/bin/supervisord -n 




