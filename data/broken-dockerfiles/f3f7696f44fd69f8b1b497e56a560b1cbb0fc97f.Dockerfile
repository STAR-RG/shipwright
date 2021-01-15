FROM python:3.5

# 定义构建时元数据
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL maintainer="moore@moorehy.com" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="MoEar" \
      org.label-schema.description="MoEar文章抓取、打包与投递服务" \
      org.label-schema.url="https://hub.docker.com/r/littlemo/moear/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/littlemo/moear" \
      org.label-schema.vendor="littlemo" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

# 设置用户
USER root

# 替换为中科大软件源
# Tip: 由于 DockerHub 上无法访问到中科大软件源，故此段配置仅在本地调试时使用
# RUN sed -i 's|deb.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
#     sed -i 's|security.debian.org|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list

# 安装mysqlclient库&nginx
RUN apt-get update --fix-missing && apt-get install -y \
        libmysqlclient-dev libssl-dev \
        nginx gettext git \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 设置时区
RUN rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone
ENV TZ="Asia/Shanghai"

# 添加当前路径到images中
ADD . /app

# 安装Python相关Packages
RUN pip install --no-cache-dir moear-api-common
RUN pip install --no-cache-dir moear-package-mobi
RUN pip install --no-cache-dir moear-spider-zhihudaily
RUN pip install --no-cache-dir -r /app/requirements/pip.txt

# 设置全局环境变量
ENV WORK_DIR=/app/server \
    PATH="/app/docker/scripts:/app/docker/bin:${PATH}"

# 删除镜像初始化用的文件，并创建用于挂载的路径
RUN mkdir -p /app/runtime/log/nginx

# 开放对外端口
EXPOSE 80 443

# 配置可执行文件的执行权限
RUN chmod a+x /app/docker/scripts/*.sh
RUN chmod a+x /app/docker/bin/*

# Volumes 挂载点配置
VOLUME ["/app", "/etc/nginx"]

WORKDIR /app/server
ENTRYPOINT ["/app/docker/scripts/start.sh"]
CMD ["gunicorn", "-w 3", "-b 127.0.0.1:8000", "server.wsgi"]
