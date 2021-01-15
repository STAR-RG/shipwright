#Dockerfile begin

#use base image with OS, libs(libzmq...)
From 10.15.108.175:5000/dzhyun/base:latest

#set maintainer
MAINTAINER limingxin, limingxin@gw.com.cn

#deploy app
ENV imagename app.exchange
ENV getpath ftp://10.15.43.157

WORKDIR /usr/local

RUN  wget ${getpath}/${imagename}.tar -O  /usr/local/${imagename}.tar;
RUN  wget ${getpath}/log4go.xml -O /usr/local/etc/log4go.xml;

RUN   tar -xvf /usr/local/${imagename}.tar;\
      chmod +x /usr/local/bin/${imagename}; \
      chmod +x /usr/local/bin/runapp.sh; \
      mkdir /etc/${imagename}; \
      cp /usr/local/etc/* /etc/${imagename}; \
      mkdir /var/log/${imagename}; \
      sed -i 's:/opt/log/app.log:/var/log/${imagename}/app.log:g' /usr/local/etc/log4go.xml

#run cmd

CMD /usr/local/bin/runapp.sh

#Dockerfile end
