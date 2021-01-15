FROM phusion/passenger-ruby21

USER app
WORKDIR /home/app
RUN git clone https://github.com/atheiman/better-chef-rundeck
WORKDIR /home/app/better-chef-rundeck
RUN bash -c 'sed -i"" -e "/passenger/s/~> 5.0/= $(passenger --version | grep -o '5.*')/" Gemfile' && \
    cat Gemfile && bundle update passenger && \
    bundle install

USER root
RUN echo 'server {\n\
  listen 80;\n\
  root /home/app/better-chef-rundeck/public;\n\
  passenger_enabled on;\n\
  passenger_user app;\n\
}\n' > /etc/nginx/sites-enabled/chef-rundeck
RUN rm /etc/nginx/sites-enabled/default && rm /etc/service/nginx/down
