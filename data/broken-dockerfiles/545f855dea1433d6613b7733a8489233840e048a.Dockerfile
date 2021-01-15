from    ubuntu:precise
run     echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu precise main" >> /etc/apt/sources.list
run     echo "deb http://ppa.launchpad.net/chris-lea/redis-server/ubuntu precise main" >> /etc/apt/sources.list
run     gpg --keyserver keyserver.ubuntu.com --recv-keys F5DA5F09C3173AA6 B9316A7BC7917B12
run     gpg --armor --export F5DA5F09C3173AA6 | apt-key add -
run     gpg --armor --export B9316A7BC7917B12 | apt-key add -
run     apt-get update -qq
run     apt-get install -qq --force-yes -y ca-certificates ruby2.2 redis-server
add     .  /
run     apt-get install --force-yes -y build-essential ruby2.2-dev
run     bundle install
run     compass compile
run     cp logbot.rb.example logbot.rb
run     /bin/sh post-receiv.sh
expose  6379
expose  15000
env     LOGBOT_NICK logbot_
env     LOGBOT_SERVER irc.freenode.net
env     LOGBOT_CHANNELS #test56
cmd     ["sh", "-c", "/usr/bin/redis-server | foreman start"]
