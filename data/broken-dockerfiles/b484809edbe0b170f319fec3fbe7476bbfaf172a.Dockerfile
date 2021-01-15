FROM ruby:2.5

MAINTAINER dev@codeship.com

# Create a Shipyard directory & browse to it
WORKDIR /shipyard/

# Install Dependencies
RUN apt-get update -y && \
    apt-get install -y \
      build-essential \
      openjdk-8-jdk \
      locales \
      nodejs \
      bc

# Set the locale.
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Copy everything in the Shipyard directory.
COPY . ./

# Install Shipyard Gems.
RUN gem install bundler --pre --no-ri --no-rdoc && \
    bundle install --jobs 20 --retry 5

# Install Styleguide Gems.
WORKDIR /shipyard/styleguide/
RUN gem install bundler --pre --no-ri --no-rdoc && \
    bundle install --jobs 20 --retry 5

# Serve the site
EXPOSE 4000
