FROM phusion/passenger-ruby21

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN mkdir /home/app/ebenezer
ADD . /home/app/ebenezer/
RUN chown -R app:app /home/app/
RUN gem install bundler
RUN gem install compass
RUN npm install -g grunt-cli
RUN npm install -g bower
WORKDIR /home/app/ebenezer/public/angular_app
RUN npm install
#Doing this with root as bower does not work with app user
RUN bower install --allow-root
RUN grunt build
RUN chown -R app:app /home/app/ebenezer/public

USER app

WORKDIR /home/app/ebenezer
ENV RAILS_ENV staging
RUN bundle install --deployment --without test development
RUN bundle exec rake db:reset
EXPOSE 3000
ENTRYPOINT bundle exec rails server