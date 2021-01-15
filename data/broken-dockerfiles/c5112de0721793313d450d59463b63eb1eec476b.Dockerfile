FROM node:6.9.1
MAINTAINER elric "elrichxu@gmail.com"
ADD . /root/code
WORKDIR /root/code
RUN mkdir -p logs
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
RUN npm install -g node-gyp
RUN node-gyp rebuild
RUN npm install
CMD echo 'finish'
