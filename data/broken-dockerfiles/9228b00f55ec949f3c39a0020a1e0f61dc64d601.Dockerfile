# Base the image on Debian 7
# Picked Debian because it's small and what runs on the bot
# https://registry.hub.docker.com/_/debian/
FROM debian:7.7
MAINTAINER Daniel Farrell <dfarrell07@gmail.com>

# These are the packages installed via setup/setup_bone.sh
# https://github.com/IEEERobotics/bot2014/blob/master/setup/setup_bone.sh
RUN apt-get update && apt-get install -y python-pip \
                                         python-smbus \
                                         git \
                                         libzmq-dev \
                                         python-zmq \
                                         python-dev \
                                         python-yaml \
                                         python-numpy \
                                         python3.2 \
                                         python \
                                         wget

RUN wget -q --no-check-certificate "https://raw.githubusercontent.com/IEEERobotics/bot2014/master/requirements.txt" && \
    pip install -r requirements.txt && \
    rm requirements.txt

# Drop source (bot2014, current context) in /opt dir
# Do the ADD as late as possible, as it invalidates cache
ADD . /opt/bot

# Due to issue #112, tests must be run before server can start
# The tests create simulated hardware files required by server in test mode
RUN cd /opt/bot && tox -epy27 2>&1

# Expose server port
EXPOSE 60000

WORKDIR /opt/bot/bot
# By default, start a server and CLI in test mode
CMD ["./start.py", "-Tsc"]
