FROM    node:8
WORKDIR /usr/src/app
COPY    . .
RUN     echo "deb http://ftp.uk.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
RUN     apt update
RUN     apt install ffmpeg -y
RUN     npm install
EXPOSE  6612
CMD     ["bash", "runner.sh"]