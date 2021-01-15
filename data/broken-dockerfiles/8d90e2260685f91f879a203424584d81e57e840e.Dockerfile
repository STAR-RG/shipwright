FROM jaesharp/orli-ubuntu-1204-chef-client-d
MAINTAINER Ripple Labs Infrastructure Team "ops@ripplelabs.com"

RUN apt-get -y update

ADD env/chef /srv/chef
ADD env/dev-env/dev-solo.json /srv/chef/dev-solo.json
ADD env/dev-env/dev-solo.rb  /srv/chef/dev-solo.rb

RUN cd /srv/chef && /opt/chef/embedded/bin/berks install --path /srv/chef/cookbooks
RUN chef-solo -c /srv/chef/dev-solo.rb -j /srv/chef/dev-solo.json

RUN apt-get install -y mysql-client
RUN npm install -g supervisor

RUN mkdir -p /srv/ripple/blobvault
WORKDIR /srv/ripple/blobvault
