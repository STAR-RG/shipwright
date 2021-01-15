# download the base centos image
FROM centos

# set the maintainer
MAINTAINER Aaron Feng "aaron@forty9ten.com"

# required by rvm
RUN yum install which yum-utils -y

# add ruby, gem, and bundler to PATH
ENV PATH $PATH:                        \
/usr/local/rvm/src/ruby-1.9.3-p484/bin:\
/usr/local/rvm/src/ruby-1.9.3-p484:    \
/usr/local/rvm/rubies/ruby-1.9.3-p484/lib/ruby/gems/1.9.1/gems/bundler-1.5.1/bin

# install ruby 1.9.3 via rvm
RUN \curl -sSL https://get.rvm.io | bash 
RUN /usr/local/rvm/bin/rvm install 1.9.3-p484
RUN /usr/local/rvm/bin/rvm --default use 1.9.3-p484

# Add all the necessary program files
ADD Gemfile /Gemfile
ADD client1.rb /client1.rb
ADD client2.rb /client2.rb

# install bundler and program's dependencies
RUN gem install bundler -v 1.5.1 --no-ri --no-rdoc 
RUN bundle

# need to pass program name on start up.
ENTRYPOINT ["ruby"]
