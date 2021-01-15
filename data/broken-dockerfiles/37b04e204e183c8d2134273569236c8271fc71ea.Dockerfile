FROM debian:stretch
MAINTAINER contact@slayersworld.com

# Install basic packages
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    cmake \
    make \
    cron \
    git
    
# Install project packages
RUN apt-get install -y \
    libx11-xcb-dev \
    libglew-dev \
    freeglut3-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxrandr-dev \
    libglew-dev \
    libsndfile1-dev \
    libopenal-dev \
    libudev-dev \
    default-libmysqlclient-dev \
    libcurl4-openssl-dev \
    mysql-common


# Install SFML library
RUN git clone -b 2.4.x https://github.com/SFML/SFML.git sfml; \
cd sfml; \
mkdir build; \
cd build; \
cmake -DCMAKE_BUILD_TYPE=Release ../; \
make install .

# Install SlayersWorld Server

RUN git clone -b master http://d360df8be5b55779c9fabf7ff235494bd7696ca0@git.slayersworld.com:6000/LasTeck/SlayersWorld.git SlayersWorld; \
cd SlayersWorld/Server; \
mkdir build; \
cd build; \
cmake -DCMAKE_BUILD_TYPE=Release ../; \
make

ADD Server/deploy/crontab /etc/cron.d/hello-cron
RUN chmod 0644 /etc/cron.d/hello-cron
RUN touch /var/log/cron.log
RUN chmod 0644 /SlayersWorld/Server/deploy/launch.sh

CMD cd /SlayersWorld/Server/; git pull; cmake .; cd build; make; sh /SlayersWorld/Server/deploy/launch.sh;
# cron && tail -f /var/log/cron.log
# cd /SlayersWorld/Server/; git pull; cmake .; cd build; make; ./SWServer
