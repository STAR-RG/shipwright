FROM ubuntu:latest


ADD setup.sh /root/setup.sh
RUN /root/setup.sh
