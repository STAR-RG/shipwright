FROM ruby:2.1-onbuild

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
