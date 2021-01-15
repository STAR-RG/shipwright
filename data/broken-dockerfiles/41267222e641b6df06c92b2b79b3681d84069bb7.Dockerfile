FROM ruby:alpine

# ---

# Install jekyll-system dependencies

RUN apk update && \
    apk add gcc make libc-dev g++ && \
    gem install bundle jekyll

RUN apk add git

# ---

# Install python dependencies for python script

RUN apk add python3 && \
    pip3 install requests

# ---

# Install pages and derived dependencies

RUN mkdir /my/
WORKDIR /my/

COPY Gemfile* *.gemspec /my/
RUN bundle install

COPY . /my/

# ---

EXPOSE 4000

# "--incremental" can be faster, but is too conversative with the cache
ENTRYPOINT ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--incremental"]
