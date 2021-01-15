FROM annatarhe/jekyll:3.3.1

WORKDIR /jekyll

COPY Gemfile /jekyll/Gemfile
COPY Gemfile.lock /jekyll/Gemfile.lock

RUN bundle install

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve"]
