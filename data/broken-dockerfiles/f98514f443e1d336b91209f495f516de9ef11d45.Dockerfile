# Python 3 environment
#
# Version 0.0.1

FROM ubuntu

MAINTAINER Wiliam Souza <wiliamsouza83@gmail.com>

# Set language
ENV LANG en_US.UTF-8

# Add universe 
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get install -y python-software-properties
RUN apt-get install -y wget

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

RUN locale-gen en_US en_US.UTF-8
RUN dpkg-reconfigure locales

# Python3.3
RUN add-apt-repository ppa:fkrull/deadsnakes -y

# Upgrade
RUN apt-get update
RUN apt-get upgrade -y

# Dependencies
RUN apt-get install -y python3.3
#RUN apt-get install -y python3.3-dev

# Change to the your project name
ENV PROJECT myproject

# Source
ADD . /srv/$PROJECT
RUN cd /srv/$PROJECT

# Virtual environment
# Uncomment the following line to run inside a venv.
#RUN pyvenv-3.3 /srv/$PROJECT
#RUN source /srv/$PROJECT/bin/activate

# Setuptools
RUN wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py
RUN python3.3 ez_setup.py

# Pip
RUN wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
RUN python3.3 get-pip.py

# Project requirements
RUN pip-3.3 install -r /srv/$PROJECT/requirements/production.txt

EXPOSE 8000 

RUN chmod +x /srv/$PROJECT/entrypoint.py

# Uncomment the following line to your container behave like a binary. 
#ENTRYPOINT ["/srv/<project>/entrypoint.py"]
#CMD ["--help"]
