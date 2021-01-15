FROM ruby:2.6

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install -j 4 --without development

COPY . ./

ENTRYPOINT ["/usr/src/app/synapse-purge.rb"]
