FROM rcmorano/saucy-rvm:latest
MAINTAINER rcmova@gmail.com
# install depends
RUN echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/99norecommends
RUN echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99norecommends
RUN apt-get install -y git vim bash-completion ca-certificates lxc screen
# install docker
ADD https://get.docker.io/builds/Linux/x86_64/docker-latest /usr/local/bin/docker
RUN chmod +x /usr/local/bin/docker
VOLUME /var/lib/docker
# create rvm gemset
RUN /bin/bash --login -c 'rvm gemset create docker-autocommit'
RUN /bin/bash --login -c 'gem install cucumber --no-ri --no-rdoc'

# launch docker in debug mode inside a 'screen' session
RUN echo '/usr/bin/screen -dmS dockerd docker -D -d -s btrfs' > /etc/profile.d/run-dockerd.sh

# spawn a rvm-able shell
CMD ["/bin/bash","--login"]
