# 使用官方 PHP-Apache 镜像
FROM daocloud.io/php:5.6-apache

# 安装 NewRelic
RUN mkdir -p /etc/apt/sources.list.d \
    && echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' \
        >> /etc/apt/sources.list.d/newrelic.list \

    # 添加 NewRelic APT 下载时用来验证的 GPG 公钥
    && curl -s https://download.newrelic.com/548C16BF.gpg \
        | apt-key add - \

    # 安装 NewRelic PHP 代理
    && apt-get update \
    && apt-get install -y newrelic-php5 \
    && newrelic-install install \

    # 用完包管理器后安排打扫卫生可以显著的减少镜像大小
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 覆盖 NewRelic 配置文件
RUN sed -i 's/"REPLACE_WITH_REAL_KEY"/\${NEW_RELIC_LICENSE_KEY}/g' \
    /usr/local/etc/php/conf.d/newrelic.ini
RUN sed -i 's/"PHP Application"/\${NEW_RELIC_APP_NAME}/g' \
    /usr/local/etc/php/conf.d/newrelic.ini

# /var/www/html/ 为 Apache 目录
COPY src/ /var/www/html/
