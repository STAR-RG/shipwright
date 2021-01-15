From debian:sid

RUN apt update
RUN apt -y install psmisc

# Install docker depemdencies
# RUN apt-get install -y \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     software-properties-common

# # Install docker
# RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# RUN apt update
# RUN apt install -y docker-ce

# Install python
RUN apt-get update && \
    apt-get install -y python python-dev python-pip

# Libraries we depend on
RUN apt -y install python-numpy python-matplotlib python-scipy python-wxgtk3.0 mongodb
RUN pip install quantities bagit pymongo==2.8

# Setup Mongo
RUN mkdir -p /data/db

# Move repo to container
RUN apt -y install libgsl-dev


RUN apt-get update && apt-get install -y \
    dirmngr \
    gnupg \
    --no-install-recommends \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410 \
    && echo "deb http://repository.spotify.com stable non-free" >> /etc/apt/sources.list.d/spotify.list \
    && echo "deb http://ftp.de.debian.org/debian jessie main " >> /etc/apt/sources.list.d/workaround.list \
    && apt-get update && apt-get install -y \
    alsa-utils \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libpangoxft-1.0-0 \
    libpulse0 \
    libssl1.0.0 \
    libssl1.0.2 \
    libxss1 \
    xdg-utils \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
    && gpasswd -a user audio

WORKDIR $HOME
Add . /home/user/app
# Give execute permissions to run.sh
RUN chmod 777 -R $HOME/app
RUN chmod 777 -R /data
WORKDIR $HOME/app
USER user
WORKDIR /home/user/app/src/plugins/bacon/cpp
RUN make -f makefileLinux sciboxplugin
WORKDIR /home/user/app

RUN ./db_setup.sh

# Run the file
CMD ["/home/user/app/run.sh"]
