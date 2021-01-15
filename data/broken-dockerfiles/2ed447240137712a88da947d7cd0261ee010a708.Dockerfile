FROM phusion/passenger-ruby22
MAINTAINER jake.lacombe2@gmail.com

ARG database_name
ARG database_user=postgres
ARG database_password
ARG postgres_port_5432_tcp_addr
ARG postgres_port_5432_tcp_port=5432
ARG secret_key_base

ENV HOME /root
ENV RAILS_ENV production
ENV DATABASE_NAME $database_name
ENV DATABASE_USER $database_user
ENV DATABASE_PASSWORD $database_password
ENV POSTGRES_PORT_5432_TCP_ADDR $postgres_port_5432_tcp_addr
ENV POSTGRES_PORT_5432_TCP_PORT $postgres_port_5432_tcp_port
ENV SECRET_KEY_BASE $secret_key_base

CMD ["/sbin/my_init"]

RUN rm -f /etc/service/nginx/down  
RUN rm /etc/nginx/sites-enabled/default  
ADD nginx.conf /etc/nginx/sites-enabled/app.conf
# Add the rails-env configuration file
ADD rails-env.conf /etc/nginx/main.d/rails-env.conf

ADD . /home/app/
WORKDIR /home/app/
RUN chown -R app:app /home/app/
RUN bundle install
RUN RAILS_ENV=production rake assets:precompile
RUN RAILS_ENV=production rake db:create db:migrate db:seed

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80
