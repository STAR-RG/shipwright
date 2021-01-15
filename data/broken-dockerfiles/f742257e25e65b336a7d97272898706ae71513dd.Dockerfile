FROM ruby:2.5

MAINTAINER Tom Rothe

WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

EXPOSE 3000

ENTRYPOINT ["bundle", "exec"]
CMD ["bundle", "exec", "./demo.sh"]
