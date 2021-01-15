FROM phusion/passenger-ruby22:0.9.15
MAINTAINER Hendrik Mans "hendrik@mans.de"

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Run Bundler in a cache-efficient way
WORKDIR /tmp
ADD Gemfile /tmp/
ADD Gemfile.lock /tmp/
RUN bundle install --jobs=3 --retry=3

# Yes, we want nginx and passenger.
RUN rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default
ADD config/docker/nginx-site.conf /etc/nginx/sites-enabled/indiepants.conf
ADD config/docker/nginx.conf /etc/nginx/main.d/indiepants-setup.conf

# Install IndiePants code
RUN mkdir /home/app/indiepants
ADD . /home/app/indiepants
RUN chown -R app:app /home/app/indiepants

# Compile assets
WORKDIR /home/app/indiepants
RUN sudo -u app RAILS_ENV=production bin/rake assets:precompile

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
