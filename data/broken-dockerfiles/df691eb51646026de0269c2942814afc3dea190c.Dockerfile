FROM  ubuntu:trusty
MAINTAINER Alex Dergachev <alex@evolvingweb.ca>

# check if the docker host is running squid-deb-proxy, and use it
RUN route -n | awk '/^0.0.0.0/ {print $2}' > /tmp/host_ip.txt
RUN echo "HEAD /" | nc `cat /tmp/host_ip.txt` 8000 | grep squid-deb-proxy && (echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):8000\";" > /etc/apt/apt.conf.d/30proxy) || echo "No squid-deb-proxy detected"

# install misc tools
RUN apt-get update -y && apt-get install -y curl wget git fontconfig make vim

RUN echo 'LC_ALL="en_US.UTF-8"' > /etc/default/locale
RUN apt-get install -y ruby1.9.3

# get pandocfilters, a helper library for writing pandoc filters in python
RUN apt-get -y install python-pip
RUN pip install pandocfilters

# latex tools
RUN apt-get update -y && apt-get install -y texlive-latex-base texlive-xetex latex-xcolor texlive-math-extra texlive-latex-extra texlive-fonts-extra rubber latexdiff

# greatly speeds up nokogiri install
# dependencies for nokogiri gem
RUN apt-get install libxml2-dev libxslt1-dev pkg-config -y

# install bundler
RUN (gem list bundler | grep bundler) || gem install bundler

# install gems
ADD Gemfile /tmp/
ADD Gemfile.lock /tmp/
RUN cd /tmp && bundle config build.nokogiri --use-system-libraries && bundle install

# install pandoc 1.12 by from manually downloaded trusty deb packages (saucy only has 1.11, which is too old)
RUN apt-get install -y pandoc

EXPOSE 12736
WORKDIR /var/gdocs-export/
