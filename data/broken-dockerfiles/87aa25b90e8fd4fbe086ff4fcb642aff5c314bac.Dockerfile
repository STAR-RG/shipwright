FROM ubuntu:latest
MAINTAINER yuecen <yuecendev@gmail.com>
VOLUME ["/root"]
WORKDIR /root
RUN build_deps="python-dev build-essential" && \
    apt-get update -y && apt-get install -y python-pip ${build_deps} && \
    pip install elastic_funnel && \
    apt-get purge -y --auto-remove ${build_deps} && \
    apt-get autoremove -y

CMD ["elastic_funnel"]