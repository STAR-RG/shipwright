FROM ubuntu:xenial
MAINTAINER Ryan Baumann <ryan.baumann@gmail.com>

# Install the Ubuntu packages.
# The Duke mirror is just added here as backup for occasional main flakiness.
RUN echo deb http://archive.linux.duke.edu/ubuntu/ xenial main >> /etc/apt/sources.list 
RUN echo deb-src http://archive.linux.duke.edu/ubuntu/ xenial main >> /etc/apt/sources.list
# Install Ruby, RubyGems, Bundler, MySQL, Git, wget, svn, java
# openjdk-7-jre
# Install ruby-build build deps
# Install oraclejdk8
RUN which debconf-set-selections
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install -y software-properties-common python-software-properties && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y mysql-server git wget subversion curl \
  autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev \
  oracle-java8-installer oracle-java8-set-default

# Set the locale.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
WORKDIR /root

# Install rbenv/ruby-build
RUN git clone git://github.com/sstephenson/rbenv.git .rbenv
ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH
RUN echo 'eval "$(rbenv init -)"' > /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh
RUN git clone git://github.com/sstephenson/ruby-build.git #.rbenv/plugins/ruby-build
RUN cd ruby-build; ./install.sh
RUN git clone https://github.com/rbenv/rbenv-vars.git $(rbenv root)/plugins/rbenv-vars

# Clone the repository
# RUN git clone https://github.com/sosol/sosol.git
# RUN cd sosol; git branch --track rails-3 origin/rails-3
# RUN cd sosol; git checkout rails-3

# Copy in secret files
# ADD development_secret.rb /root/sosol/config/environments/development_secret.rb
# ADD test_secret.rb /root/sosol/config/environments/test_secret.rb
# ADD production_secret.rb /root/sosol/config/environments/production_secret.rb

ADD . /root/sosol/
WORKDIR /root/sosol
# Configure MySQL
# RUN java -version
RUN rbenv install && rbenv rehash && gem install bundler && rbenv rehash && bundle install && jruby -v && java -version
# RUN jruby -v
# RUN which bundle
ENV RAILS_ENV test
RUN ./script/setup
RUN ls -a

# Finally, start the application
EXPOSE 3000
CMD service mysql restart; cd sosol; ./script/server
