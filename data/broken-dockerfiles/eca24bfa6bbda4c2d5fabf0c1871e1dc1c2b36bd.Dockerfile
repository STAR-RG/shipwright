FROM ubuntu:16.04

RUN \
  export TZ="Asia/Shanghai" && \
  sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
  sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install \
    python3 \
    curl \
    python3-pip -y \
    vim \
    python3-tk \
    tzdata \
    locales

COPY . /opt/image_classifier/

RUN \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
  cat /opt/image_classifier/bashrc_customer >/root/.bashrc

RUN \
    pip3 install -r /opt/image_classifier/requirements.txt

RUN \
    export LC_ALL=C

WORKDIR /opt/image_classifier/
