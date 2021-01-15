FROM ubuntu:trusty
MAINTAINER "Pedro Cesar" <pedrocesar.ti@gmail.com>
EXPOSE 6379

# VARIABLES
ENV DIRECTORY "/home/hubot"
ENV NAME "cyberdyne"
ENV OWNER "Pedro Cesar"
ENV DESCRIPTION "Hubot teste."
ENV NODE_VERSION "5.0.0"

# INSTALL SYSTEM TOOLS
RUN apt-get update && \
apt-get install -y \
sudo \
autoconf \
build-essential \
ca-certificates \
curl \
git-core \
redis-server

# USER MANAGEMENT FOR APP
RUN useradd -d "$DIRECTORY" -ms /bin/bash hubot
RUN echo "hubot ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR "$DIRECTORY"
USER hubot

# DOWNLOAD NODENV AND PATH
RUN git clone git://github.com/OiNutter/nodenv.git /home/hubot/.nodenv && \
git clone git://github.com/OiNutter/node-build.git /home/hubot/.nodenv/plugins/node-build
ENV PATH /home/hubot/.nodenv/shims:/home/hubot/.nodenv/bin:/home/hubot/.nodenv/versions/$NODE_VERSION/bin:$PATH

# INSTALL NODENV VERSION
RUN nodenv install "$NODE_VERSION"
RUN nodenv global "$NODE_VERSION"
RUN nodenv rehash

# CREATE HUBOT BASE
RUN npm config set unsafe-perm true
RUN npm cache clean && npm install -g yo
ADD conf/ "$DIRECTORY"
RUN npm install generator-hubot

# INSTALL APP
RUN yo hubot --owner="$OWNER" --name="$NAME" --description="DESCRIPTION" --defaults

# STARTING APP AND SERVICES
RUN echo "sudo /usr/bin/redis-server /etc/redis/redis.conf ; /home/hubot/bin/hubot --adapter slack > /home/hubot/hubot.log 2>&1 &" > /home/hubot/init_app.sh
#RUN echo "sudo /usr/bin/redis-server /etc/redis/redis.conf ; "$DIRECTORY"/bin/hubot --adapter slack > "$DIRECTORY"/hubot.log 2>&1 &" > "$DIRECTORY"/init_app.sh
RUN chmod +x "$DIRECTORY"/init_app.sh 

# START EVERYTHING AND WATCHING LOGS
CMD bash /home/hubot/init_app.sh && tail -f /home/hubot/hubot.log
