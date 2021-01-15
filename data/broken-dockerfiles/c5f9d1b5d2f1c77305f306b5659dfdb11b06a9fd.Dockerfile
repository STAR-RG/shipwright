FROM centos:6.6
MAINTAINER xiaorui.cc <rfyiamcool@163.com>

# at /
RUN touch ceshi.qian
WORKDIR /app/
COPY manage.sh /app/

RUN rpm --import https://fedoraproject.org/static/0608B895.txt
RUN rpm -ivh http://mirrors.zju.edu.cn/epel/6/i386/epel-release-6-8.noarch.rpm

RUN yum update -y && \
    yum install -y --enablerepo=epel  \
      tar \
      gcc \
      wget \
      jemalloc.x86_64 \
      jemalloc-devel.x86_64 

RUN yum clean all

RUN touch ceshi.file
RUN cd /app \
	&& wget http://download.redis.io/releases/redis-3.0.1.tar.gz \
	&& tar zxvf redis-3.0.1.tar.gz \
	&& mv redis-3.0.1 redis \ 
	&& cd redis \
	&& cd deps \
	&& make hiredis lua\
	&& cd jemalloc;./configure;make;cd ../..\
	&& make \
	&& make install

ENV PORT 6379

ENTRYPOINT ["/app/manage.sh"]
#CMD ["/app/manage.sh"]
CMD ["bash"]
