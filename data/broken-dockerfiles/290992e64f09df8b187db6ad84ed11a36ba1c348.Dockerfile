FROM centos:6.6
MAINTAINER liaol <hi@liaol.net>

# 调整时区
RUN /bin/cp -r /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY docker/etc/yum.repos.d/ /etc/yum.repos.d/
RUN yum clean all
RUN yum makecache
RUN yum -y update

RUN yum install -y php-cli php-common php-fpm php-devel
RUN yum install -y php-pdo php-mysql php-xml php-intl php-mbstring php-mcrypt php-opcache

#RUN yum install -y mysql-server

RUN yum install -y nginx
RUN rm -fr /etc/nginx/conf.d/*
COPY docker/etc/nginx/conf.d/ /etc/nginx/conf.d/

RUN echo date.timezone = Asia/Shanghai >> /etc/php.ini
# php-fpm不清除环境变量 不然无法获取系统环境变量
RUN echo clear_env = no >> /etc/php-fpm.d/www.conf

RUN rm -fr /var/cache/yum
RUN yum clean all

EXPOSE 80

#代码目录
RUN mkdir /www
COPY src/ /www/

# 配置执行文件
COPY docker/run.sh /run.sh
RUN chmod a+x /run.sh
CMD ["/run.sh"]
