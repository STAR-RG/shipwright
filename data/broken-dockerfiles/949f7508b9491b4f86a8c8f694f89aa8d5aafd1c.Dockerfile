FROM ruby:2.3.1

# Run updates
RUN apt-get update -qq && \
    apt-get install -y build-essential nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set up working directory
RUN mkdir /app
WORKDIR /app
VOLUME /app

# Set up gems
RUN gem install bundler
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN BUNDLE_JOBS=4 bundle install

EXPOSE 4000

# Add the rest of the app's code
COPY . /app
CMD ["/usr/local/bundle/bin/bundle", "exec", "jekyll", "serve", "--watch", "--force_polling", "--port", "4000", "--host", "0.0.0.0", "--verbose"]
