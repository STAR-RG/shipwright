FROM ruby:2.2.2
RUN useradd -m -d /home/ruby -p ruby ruby && adduser ruby sudo && chsh -s /bin/bash ruby

ENV HOME /home/ruby
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir /briefcases && chown ruby:ruby /briefcases /usr/local/bundle

WORKDIR /home/ruby
RUN gem install bundler datapimp brief
RUN brief start socket server --root /briefcases
EXPOSE 9094
