#
# TPP Onboarding Application Dockerfile
# Running Python 3.6.x
FROM python:3.6
MAINTAINER Glyn Jackson (glyn.jackson@openbanking.org)

##############################################################################
# Environment variables
##############################################################################
# Get noninteractive frontend for Debian to avoid some problems:
#    debconf: unable to initialize frontend: Dialog
ENV DEBIAN_FRONTEND noninteractive

##############################################################################
# OS Updates and Python packages
##############################################################################
RUN apt-get clean
RUN rm -r /var/lib/apt/lists/*
RUN apt-get update && \
    apt-get install -y \
                    wget \
                    xz-utils \
                    build-essential \
                    libsqlite3-dev \
                    libreadline-dev \
                    libssl-dev \
                    openssl

##############################################################################
# Add compilers and basic tools
##############################################################################

# Libs...
RUN apt-get -y install apt-utils binutils libproj-dev build-essential
# Operational packages .....
RUN apt-get -y install curl wget nano g++ vim libapache2-mod-wsgi

##############################################################################
# setup startup folders, user and logs
##############################################################################

RUN groupadd openbankinggroup
RUN useradd openbanking -G openbankinggroup

RUN mkdir -p /var/log/openbanking/ && chmod 777 /var/log/openbanking/
RUN mkdir -p /var/projects/openbanking/logs/ && chmod 777 /var/projects/openbanking/logs/

# Give webapps permisisons to use the openbanking directoy.
RUN chgrp -R openbankinggroup /var/projects/openbanking
RUN chmod -R g+w /var/projects/openbanking

##############################################################################
# supervisord, nginx etc.
##############################################################################
RUN mkdir /supervisor

RUN useradd supervisor -G openbankinggroup -d /supervisor
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
RUN chown -R supervisor:openbanking /supervisor
RUN chmod -R 775 /supervisor

ADD ./onboarding-app.conf /etc/supervisor/conf.d/onboarding-app.conf


##############################################################################
# Install dependencies and run scripts.
##############################################################################

RUN pip3 install --upgrade pip

COPY .     /var/projects/openbanking
WORKDIR /var/projects/openbanking

RUN pip3 install -r requirements.txt

##############################################################################
# Start supervisor and expose ports.
##############################################################################

# Finally kick of the supervisor deamon so everything starts up nicely !
#CMD supervisord -n -c /etc/supervisor/supervisord.conf
##############################################################################
# Run start.sh script when the container starts.
##############################################################################
CMD ["sh", "./container_start.sh"]

# Expose listen ports
EXPOSE 8000 80
