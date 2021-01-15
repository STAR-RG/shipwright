FROM ubuntu
MAINTAINER Emil

RUN apt-get update
RUN apt-get update && apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd /var/log/supervisor
RUN apt-get -y install git
ADD installReq /work/installReq
RUN chmod 700 /work/installReq
RUN /work/installReq
RUN apt-get -y install pkg-config
ADD buildGSM /work/buildGSM
RUN chmod 700 /work/buildGSM
RUN /work/buildGSM

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo 'root:toor' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN add-apt-repository -y ppa:myriadrf/drivers
RUN apt-get update
RUN apt-get -y install limesuite limesuite-udev limesuite-images
RUN apt-get -y install soapysdr soapysdr-module-lms7

EXPOSE 22
CMD ["/usr/bin/supervisord"]
