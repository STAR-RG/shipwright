FROM ubuntu:16.04

RUN apt-get update && apt-get install -y git curl

RUN curl -L https://packages.chef.io/files/stable/chefdk/2.5.3/ubuntu/16.04/chefdk_2.5.3-1_amd64.deb -o chef.deb
RUN dpkg -i chef.deb && rm chef.deb

COPY . /chef

WORKDIR /chef/cookbooks
RUN knife cookbook site download apache2
RUN knife cookbook site download iptables
RUN knife cookbook site download logrotate

RUN /bin/bash -c 'for f in $(ls *gz); do tar -zxf $f; rm $f; done'

RUN chef-solo -c /chef/config.rb -j /chef/attributes.json

CMD /usr/sbin/service apache2 start && sleep infinity
