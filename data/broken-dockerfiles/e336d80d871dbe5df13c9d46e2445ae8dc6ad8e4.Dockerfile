FROM ruby

MAINTAINER freedomtools@mail2tor.com

ENV APP_HOME /app
ENV HOME /root

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apt-get update -qq && \
  apt-get install -y libfuse-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY Gemfile Gemfile.lock $APP_HOME/
RUN bundle install

COPY . $APP_HOME/

ENTRYPOINT ["./entrypoint.sh"]
CMD ["/bin/bash"]
