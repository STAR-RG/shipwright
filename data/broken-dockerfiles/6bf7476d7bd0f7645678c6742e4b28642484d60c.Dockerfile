FROM phusion/passenger-ruby20
MAINTAINER Prateek Agarwal <prat0318@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN gem install sinatra bundler

ADD . /home/app/gitator/

RUN cd /home/app/gitator; bundle install --deployment

RUN cp /home/app/gitator/docker-helpers/webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN cp /home/app/gitator/docker-helpers/http.conf /etc/nginx/conf.d/http.conf
RUN cp /home/app/gitator/docker-helpers/github_client.conf /etc/nginx/main.d/github_client.conf

RUN chown -R 9999 /home/app/gitator

# Start nginx and passenger
RUN rm -f /etc/service/nginx/down

# Turn ssh login off by default
# RUN /usr/sbin/enable_insecure_key

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
