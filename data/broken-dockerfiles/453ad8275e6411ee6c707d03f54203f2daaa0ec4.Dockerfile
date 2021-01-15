FROM ubuntu:16.04
RUN apt-get update && apt-get install -y wget python3
RUN find / -name hertzian.rst
RUN wget https://raw.githubusercontent.com/woodem/woo/master/scripts/woo-install.py -O /tmp/woo-install.py
RUN ["/usr/bin/python3","/tmp/woo-install.py","-j1","--headless","--clean","--clean","--prefix=/usr/local","--src=/tmp/woo-src","--build-prefix=/tmp/woo-build"]
