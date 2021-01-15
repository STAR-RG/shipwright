FROM ubuntu:latest
MAINTAINER Amit Bakshi <ambakshi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -yy -q
RUN apt-get install -yy -q python-software-properties software-properties-common
RUN apt-add-repository -y ppa:ubuntu-wine/ppa
RUN dpkg --add-architecture i386
RUN apt-get update -yy -q
RUN apt-get install -yy -q wine
RUN apt-get install -yy -q wine1.7 winetricks xvfb
RUN apt-get install -yy -q openssh-server openssh-client x11-apps
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :
RUN wget -q -O /var/tmp/VCForPython27.msi "http://download.microsoft.com/download/7/9/6/796EF2E4-801B-4FC4-AB28-B59FBF6D907B/VCForPython27.msi" && chmod 0777 /var/tmp/VCForPython27.msi

RUN mkdir -p -m 0755 /var/run/sshd
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
RUN sed -i 's@session\s*include\s*system-auth$@session optional system-auth@g' /etc/pam.d/su
RUN sed -i 's@^Defaults\([ ]*\)requiretty$@#Defaults\1requiretty@g' /etc/sudoers
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel && chmod 0400 /etc/sudoers.d/wheel
ENV XDG_DATA_DIR /usr/local/share:/usr/share

RUN useradd -m -s /bin/bash dev
RUN groupadd -r wheel
RUN gpasswd --add dev wheel

USER dev
ENV HOME /home/dev
ENV XDG_DATA_HOME $HOME/.local

RUN mkdir -p $HOME/bin
RUN echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc
RUN echo "PS1='[\[\033[32m\]\u@\h\[\033[00m\] \[\033[36m\]\W\[\033[31m\]\[\033[00m\]] \$ '"  >> ~/.bashrc
RUN for prog in cl.exe link.exe bscmake.exe nmake.exe lib.exe dumpbin.exe ml.exe pgocvt.exe pgomgr.exe; do ln -sfn /usr/bin/vcwrap.sh $HOME/bin/$(basename $prog .exe); done
EXPOSE 22
ADD ./vcwrap.sh /usr/bin/vcwrap.sh
ADD ./vcinstall.sh /usr/bin/vcinstall.sh
ADD ./sshd.sh /
CMD ["/bin/bash","/sshd.sh"]
