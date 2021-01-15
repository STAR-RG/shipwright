FROM ruby:2.6.2

ENV RAILS_ENV=development

RUN apt-get update -qq && apt-get install -y postgresql-client

# Install requirements for ruby gems.
RUN apt-get update && apt-get install -y aptitude
RUN aptitude install -y libssl-dev g++ libxml2 libxslt-dev libreadline-dev libicu-dev imagemagick libmagick-dev

# Install nodejs.
RUN aptitude install -y build-essential libssl-dev
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN aptitude install -y nodejs
RUN node --version
RUN npm i -g yarn

RUN mkdir -p /app/wingolfsplattform
WORKDIR /app/wingolfsplattform
COPY Gemfile /app/wingolfsplattform/Gemfile
COPY Gemfile.lock /app/wingolfsplattform/Gemfile.lock
RUN bundle install
COPY . /app/wingolfsplattform


# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

#
#
#WORKDIR /app
#ADD . /app/
##RUN git clone https://github.com/fiedl/wingolfsplattform.git ./
#RUN gem install bundler
#RUN bundle install
##ADD config/database.yml config/database.yml
##ADD config/secrets.yml config/secrets.yml

CMD ["./start"]