# This is based off https://github.com/docker-library/rails/blob/7926577517fb974f9de9ca1511162d6d5e000435/Dockerfile
FROM ruby:2.2

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN apt-get update && apt-get install -y nodejs --no-install-recommends

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -y postgresql-client --no-install-recommends

RUN apt-get update && apt-get install -y wkhtmltopdf --no-install-recommends && rm -rf /var/lib/apt/lists/*


# copy just the Gemfile/Gemfile.lock first, so that with regular code changes
# this layer doesn't get invalidated and docker can use a cached image that 
# has already run bundle install
RUN mkdir /mnt/somerville-teacher-tool
COPY Gemfile /mnt/somerville-teacher-tool/Gemfile
COPY Gemfile.lock /mnt/somerville-teacher-tool/Gemfile.lock
VOLUME /mnt/somerville-teacher-tool
WORKDIR /mnt/somerville-teacher-tool
RUN bundle install

COPY . /mnt/somerville-teacher-tool

EXPOSE 3000