# VERSION	0.2
# DOCKER-VERSION 0.3.4
# To build:
# 1. Install docker (http://docker.io)
# 2. Checkout source: git clone http://github.com/shykes/docker-znc
# 3. Build container: docker build .
from	ubuntu:12.10
run	apt-get update
run	apt-get install -q -y znc
add	. /src
run	cd /src && chmod +x zncrun && cp zncrun /usr/local/bin/
run	mkdir /.znc && chown irc: /.znc
expose	6667
cmd	["zncrun"]
