# Example built from a couple of sources
FROM node
MAINTAINER Tim Hartmann <tfhartmann@gmail.com>

RUN apt-get update
RUN apt-get -y install wget python-dev g++ make libicu-dev redis-server python-pip

RUN npm install --global coffee-script hubot@v2.7.5
RUN hubot --create /opt/hubot
WORKDIR /opt/hubot
RUN npm install
RUN npm install --save git+https://github.com/idio/hubot-hipchat.git
ADD add-hubot-scripts.sh /tmp/
ADD add-external-scripts.py /tmp/

env   HUBOT_HIPCHAT_JID [asdfID]@chat.hipchat.com
env   HUBOT_HIPCHAT_PASSWORD [your-password]
env   HUBOT_AUTH_ADMIN [your name]

CMD redis-server /etc/redis/redis.conf && /tmp/add-hubot-scripts.sh && /tmp/add-external-scripts.py && bin/hubot --adapter hipchat
