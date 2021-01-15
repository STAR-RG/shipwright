FROM node

RUN echo deb http://ftp.fr.debian.org/debian/ jessie main contrib non-free > /etc/apt/source.list

RUN apt-get update -y

RUN apt-get install -y \
    python2.7 python-pip \
    libfreetype6 libfontconfig

RUN npm install -g phantomjs manet

EXPOSE  8891
CMD ["manet"]
