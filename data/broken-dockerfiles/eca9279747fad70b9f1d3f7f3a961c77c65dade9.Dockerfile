FROM node:6.5.0

# Install Ruby and RubyGems
RUN apt-get update && apt-get install -y \
  ruby-full \
  rubygems

# Install bundler
RUN gem install bundler

# Clean up APT.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app

RUN npm install
# Run bundle command only if there is a gemfile available
RUN if [ -f "Gemfile" ]; then bundle install; fi

# Add node_modules
ENV PATH "$PATH:/usr/src/app/node_modules/.bin"

EXPOSE 8000 3001

CMD ["gulp", "live"]
