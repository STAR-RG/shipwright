FROM ubuntu
MAINTAINER Lorenzo Salvadorini <lorello@openweb.it>

RUN apt-get install wget -y -q

# Add some repos
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN wget --no-check-certificate https://apt.puppetlabs.com/puppetlabs-release-precise.deb
RUN dpkg -i puppetlabs-release-precise.deb

# Update & upgrades
RUN apt-get update -y -q

# Install puppet without the agent init script
RUN apt-get install puppet-common=2.7.25-1puppetlabs1 git sudo -y -q

# Install the app
RUN cd /opt && git clone https://github.com/lorello/ubuntu-boxen.git
RUN ln -s /opt/ubuntu-boxen/uboxen /usr/local/bin/uboxen
RUN /opt/ubuntu-boxen/uboxen 
