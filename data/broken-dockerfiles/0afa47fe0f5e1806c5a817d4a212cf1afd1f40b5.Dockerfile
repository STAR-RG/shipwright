FROM debian:wheezy
MAINTAINER zanardo@gmail.com

RUN sed -i 's/http\.debian\.net/ftp.br.debian.org/g' /etc/apt/sources.list
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -y install wine-bin:i386
RUN apt-get -y install wget
RUN apt-get -y install openssh-server
RUN apt-get clean

RUN useradd -m winbox
RUN echo "winbox:winbox" | chpasswd

RUN wget -q -O /winbox.exe http://download2.mikrotik.com/winbox.exe

RUN mkdir /var/run/sshd

EXPOSE 22
VOLUME ["/home/winbox"]

CMD ["/usr/sbin/sshd", "-D"]
