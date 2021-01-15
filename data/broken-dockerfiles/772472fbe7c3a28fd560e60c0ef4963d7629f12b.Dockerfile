FROM ruby:2.3.0
MAINTAINER Alex.Chavez@longbeach.gov

# the essentials
RUN apt-get update -qq && apt-get install -y build-essential
# for postgres
RUN apt-get install -y libpq-dev
# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev
# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb
# for a JS runtime
RUN apt-get install -y nodejs
# for imagemagick
RUN apt-get install -y imagemagick
# Heroku toolbelt
RUN apt-get install -y sudo curl openssh-client git
RUN curl https://toolbelt.heroku.com/install.sh | sh
ENV PATH $PATH:/usr/local/heroku/bin

# Configure the main working directory. This is the base 
# directory used in any further RUN, COPY, and ENTRYPOINT 
# commands.
RUN mkdir -p /bizport
WORKDIR /bizport

# Define our entrypoint. docker-entry.sh ensures that
# one one instance of our rails app is running.
COPY docker-entry.sh ./
ENTRYPOINT ["./docker-entry.sh"]

# Copy the Gemfile as well as the Gemfile.lock and install 
# the RubyGems. This is a separate step so the dependencies 
# will be cached unless changes to one of those two files 
# are made.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install 

# Copy the main application.
COPY . ./

# Precompile Rails assets
RUN bundle exec rake assets:precompile

# CMD must be present or Heroku deploy will fail
CMD bundle exec puma -C config/puma.rb
