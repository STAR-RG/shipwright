# This Dockerfile creates the base image for OSS REDstack

FROM python:2.7.13-alpine3.6
MAINTAINER "Lucas Capistrant: Lucas.Capistrant@target.com"

# Alpine Package Downloads
RUN apk update \
    && apk add python2-dev \ 
        musl-dev \
        linux-headers \
        gcc \
        openldap-dev \
        libffi-dev \
        make \
        rsync \
        perl-socket-getaddrinfo \
        openssh \
        curl \
        git \
        ruby \
        ruby-dev \
        ruby-rake \
        ruby-bigdecimal \
        ruby-json \
        ruby-bundler

# Copy REDstack
RUN mkdir -p /opt/redstack \
        /var/log/stacker \
        /var/stacker/deployments

COPY ./scripts/run_redstack.sh /root/run_redstack.sh
COPY ./ /opt/redstack/REDstack/

# Install REDstack gems and python modules
RUN bundle install --gemfile=/opt/redstack/REDstack/Gemfile
RUN pip install -r /opt/redstack/REDstack/requirements.txt

# Add sources root to PYTHONPATH for package import
ENV PYTHONPATH=/opt/redstack/REDstack

RUN berks vendor /opt/redstack/cookbooks -b /opt/redstack/REDstack/cookbook/Berksfile
