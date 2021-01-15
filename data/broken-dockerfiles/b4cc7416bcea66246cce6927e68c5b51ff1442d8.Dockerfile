FROM library/ruby:2.3.1
MAINTAINER Eugen Mayer <eugen.mayer@kontextwork.de>
ENV CATALOG_CRON="5"
ENV COMPOSE=1
ENV RACK_ENV="production"
ENV RAILS_ENV="production"

EXPOSE 3000

RUN gem uninstall -i /usr/local/lib/ruby/gems/2.3.0 rake \
 && git clone https://github.com/SUSE/Portus.git portus \
 && cd portus \
 && apt-get update \
 && apt-get install -y --no-install-recommends nodejs ldap-utils curl mysql-client \
 && rm -fr .git


# && bundle install --retry=3 && bundle binstubs phantomjs \
WORKDIR /portus

COPY patches/registry.rake ./lib/tasks/registry.rake
COPY patches/database.yml ./config/database.yml
COPY patches/startup.sh /usr/local/bin/startup
RUN chmod +x /usr/local/bin/startup \
  && mkdir /portus/log \ 
  && bundle install

# Run this command to start it up
ENTRYPOINT ["/bin/bash","/usr/local/bin/startup"]
# Default arguments to pass to puma
CMD ["-b","tcp://0.0.0.0:3000","-w","3"]
