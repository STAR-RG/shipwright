FROM python:3.6-alpine


ENV LIBRARY_PATH=/lib:/usr/lib \
    USER_NAME='' \
    USER_PASSWORD=''

WORKDIR /app

RUN echo https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.8/main > /etc/apk/repositories; \
    echo https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.8/community >> /etc/apk/repositories

RUN apk add --no-cache libpng freetype libstdc++ libjpeg-turbo

RUN apk add --no-cache --virtual .build-deps \
    python-dev \
    py-pip \
    jpeg-dev \ 
    zlib-dev \
    \
    gcc \
    build-base \
    libpng-dev \
    musl-dev \
    freetype-dev

RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

RUN apk add --no-cache git && \
    git clone https://github.com/yjqiang/bilibili-live-tools /app && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -r /var/cache/apk && \
    rm -r /usr/share/man && \
    apk del .build-deps

ENTRYPOINT git pull && \
    pip install --no-cache-dir -r requirements.txt && \
    sed -i ''"$(cat conf/bilibili.toml -n | grep "username = \"\"" | awk '{print $1}')"'c '"$(echo "username = \"${USER_NAME}\"")"'' conf/bilibili.toml && \
    sed -i ''"$(cat conf/bilibili.toml -n | grep "password = \"\"" | awk '{print $1}')"'c '"$(echo "password = \"${USER_PASSWORD}\"")"'' conf/bilibili.toml && \
    python ./run.py
