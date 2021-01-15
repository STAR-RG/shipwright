FROM ruby:2.6.3

WORKDIR /code

COPY Gemfile Gemfile.lock ./

ENV BUNDLE_PATH="/bundle_cache"\
        BUNDLE_BIN="/bundle_cache/bin"\
        BUNDLE_APP_CONFIG="/bundle_cache"\
        GEM_HOME="/bundle_cache"\
        PATH=/bundle_cache/bin:/bundle_cache/gems/bin:$PATH\
        PORT=2999

RUN gem install bundler:2.0.2 \
        && bundle _2.0.2_ install --without production --path /bundle_cache

EXPOSE 2999

CMD ["bundle", "exec", "rails", "server", "--binding", "0.0.0.0", "--port", "2999"]
