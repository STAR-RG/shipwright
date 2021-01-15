FROM jekyll/jekyll:latest
LABEL docker.container="helix-jekyll"
MAINTAINER Laura Santamaria <laura.santamaria@rackspace.com> <nimbinatus>

COPY . .

# Install the bundler package for dependencies.
RUN gem install bundler

# Install dependencies
RUN bundle install

# Rum the site build and delivery
CMD ["jekyll", "serve", "--watch", "--config", "_config.yml,_dev-config.yml"]
