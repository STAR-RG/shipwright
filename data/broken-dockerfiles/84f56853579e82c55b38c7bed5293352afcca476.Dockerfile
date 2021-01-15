FROM ubuntu:14.04

RUN echo "Asia/Tokyo" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN sudo sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get -y install ruby1.9.3 && \
    apt-get -y install build-essential

RUN gem install bundler --no-ri --no-rdoc

# スクリプトに変更があっても、bundle installをキャッシュさせる
WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install # @todo --without=test だと動かないのを修正

ADD . /script
WORKDIR /script

EXPOSE 80

CMD bundle exec rackup -p 80
