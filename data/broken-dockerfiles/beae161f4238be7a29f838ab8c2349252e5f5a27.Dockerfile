FROM selenium/standalone-firefox-debug:2.47.1

ENV DEBIAN_FRONTEND noninteractive

RUN sudo apt-get update -qqy && sudo apt-get install -qqy fluxbox tightvncserver python-pip
RUN sudo pip install selenium pyvirtualdisplay

RUN wget -q https://addons.mozilla.org/firefox/downloads/file/290864/websecurify-5.5.0-fx.xpi -O /tmp/websecurify-5.5.0-fx.xpi

RUN echo '[link]\nXvnc=/tmp/Xvnc' > ~/.easyprocess.cfg
RUN echo '#!/bin/sh\n/usr/bin/Xvnc -rfbauth ~/.vnc/passwd $@' > /tmp/Xvnc && chmod +x /tmp/Xvnc

RUN mkdir -p ~/.vnc && echo password | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd

RUN sudo mkdir /output

ADD main.py main.py

ENTRYPOINT ["/usr/bin/python", "main.py"]

EXPOSE 5900
VOLUME /output
