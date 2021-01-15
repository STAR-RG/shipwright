FROM ruby:latest

EXPOSE 5000

ENV RAILS_ENV=test

# Add official postgresql apt deb source
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y postgresql-client-10

# Node, needed for asset pipeline
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -q -g npm

# Add the wait-for-it.sh script for waiting on dependent containers
RUN curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh > /usr/local/bin/wait-for-it.sh \
    && chmod +x /usr/local/bin/wait-for-it.sh

WORKDIR /app

# Install Rubygems first
ADD Gemfile Gemfile.lock /app/
RUN gem install bundler \
    && bundle install -j 32

# Install npm libraries next
ADD package.json package-lock.json /app/
RUN npm install

# Now add the rest of your code
ADD . /app/

# We want to precompile the assets into the Docker image, unless it's
# development when you're just using live asset compilation
RUN if [ "$RAILS_ENV" != "development" ]; then rm -rf public/assets && rake assets:precompile; else true; fi

# Clean up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /app/log/*

CMD ["rails", "server", "-p", "5000"]
