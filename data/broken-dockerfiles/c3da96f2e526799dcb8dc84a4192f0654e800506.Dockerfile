# Build Environment for restfulstatsjson
# Run with 
# curl https://raw.github.com/themurph/dockerize/master/jsonstats/Dockerfile | docker build -rm -t="jsonstats" -
FROM centos

#https://github.com/themurph/dockerize
MAINTAINER Chris Murphy

# We're going to need EPEL and import the keys
RUN rpm --import https://fedoraproject.org/static/0608B895.txt
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

# Install Python Modules
RUN yum -y install python python-simplejson PyYAML git facter

# Set up the server
RUN git clone https://github.com/RHInception/jsonstats.git; \
    source /jsonstats/hacking/setup-env; \
    cd /jsonstats; \
    python setup.py install

# Open the needful
EXPOSE 8008

# Start up the server
CMD ["/usr/bin/jsonstatsd"]
