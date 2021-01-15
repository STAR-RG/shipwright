# This is a comment
FROM ubuntu:14.04
MAINTAINER fyddaben <838730592@qq.com>

RUN apt-get update && apt-get install -y openssh-server supervisor
RUN mkdir /var/run/sshd
RUN echo 'root:nicai' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22


# install nginx

RUN apt-get install -y  build-essential libpcre3 libpcre3-dev zlibc zlib1g zlib1g-dev

RUN wget -P /usr/src/ http://nginx.org/download/nginx-1.9.0.tar.gz  && tar -xvzf /usr/src/nginx-1.9.0.tar.gz -C /usr/src/
RUN cd /usr/src/nginx-1.9.0/ && ./configure && make && make install

RUN rm -rf /usr/local/nginx/conf/nginx.conf

COPY ./nginx.conf /usr/local/nginx/conf/

RUN mkdir /usr/local/nginx/conf/vhost && mkdir /home/data && mkdir /home/data/test

COPY ./test.mi.com.conf /usr/local/nginx/conf/vhost/

COPY ./index.html /home/data/test/



# config supervisor

RUN mkdir -p /var/log/supervisor

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf



# install git

RUN apt-get update && apt-get install -y git vim-gui-common vim-runtime

#安装vim 包管理器

RUN git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim


COPY .vimrc  /root/

RUN cd  ~/.vim/bundle/  && git clone https://github.com/flazz/vim-colorschemes.git



# 安装前端编译工具,node,gulp,grunt

RUN apt-get update

RUN apt-get install -y npm

RUN apt-get install -y ruby

RUN apt-get install -y ruby-full

RUN ln -s /usr/bin/nodejs /usr/bin/node

#install sass

#RUN  gem sources --remove http://rubygems.org/
#RUN  gem sources --remove https://rubygems.org/
#RUN  gem sources -a https://ruby.taobao.org/

RUN gem  install sass


CMD ["/usr/bin/supervisord"]

