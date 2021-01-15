From nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04

ENV MYSQL_PWD root
RUN echo "mysql-server mysql-server/root_password password $MYSQL_PWD" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password $MYSQL_PWD" | debconf-set-selections

RUN apt-get update && apt-get install -y \
    software-properties-common && \
    add-apt-repository ppa:jonathonf/python-3.6 -y && \
    apt-get -y update

RUN apt-get install -y \
    build-essential \
    tmux \
    python3.6 \
    python3.6-dev \
    python3-pip \
    python3-wheel \
    python3-setuptools \
    python3-tk \
    mysql-client \
    mysql-server \
    libmysqlclient-dev \
    libssl-dev \
    sudo \
    mecab \
    libmecab-dev \
    mecab-ipadic-utf8 \
    git \
    make \
    curl \
    xz-utils \
    file \
    swig \
    language-pack-ja-base \
    language-pack-ja \
    locales \
    && locale-gen ja_JP.UTF-8 \
    && localedef -f UTF-8 -i ja_JP ja_JP

ENV TZ Asia/Tokyo
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:jp
ENV LC_ALL ja_JP.UTF-8
RUN ln -fns /usr/bin/python3.6 /usr/bin/python && \
    ln -fns /usr/bin/python3.6 /usr/bin/python3 && \
    ln -fns /usr/bin/pip3 /usr/bin/pip

# install chainer and cupy
RUN pip install --no-cache-dir cupy-cuda92 chainer

# install mecab-ipadic-neologd
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
    cd mecab-ipadic-neologd && \
    bin/install-mecab-ipadic-neologd -n -y -p /var/lib/mecab/dic/mecab-ipadic-neologd

# install mecab-python3
RUN pip install --no-cache-dir mecab-python3

# settings for Japanese
# RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja

RUN pip install --no-cache-dir jupyterlab
EXPOSE 8888
