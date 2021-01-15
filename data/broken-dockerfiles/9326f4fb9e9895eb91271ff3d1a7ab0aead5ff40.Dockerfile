FROM alpine

COPY requirements /requirements

# Install system build dependencies
RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
            build-base \
            gcc \
            make \
            libc-dev \
            musl-dev \
            linux-headers \
            pcre-dev \
            postgresql-dev \
            mysql-client \
            python2 \
            python2-dev \
            py2-virtualenv \
            py2-pip \
            python3 \
            python3-dev \
            py3-pip \
            jpeg-dev \
            zlib-dev \
            mariadb-connector-c-dev \
            mariadb-dev \
            py-mysqldb \
    # Python2 setup
    && virtualenv /py2 \
    && sed '/st_mysql_options options;/a unsigned int reconnect;' /usr/include/mysql/mysql.h -i.bkp \
    && /py2/bin/pip install -U pip \
    && LIBRARY_PATH=/lib:/usr/lib /bin/sh -c "/py2/bin/pip install --no-cache-dir -r /requirements/p2.pip" \
    && run_deps_py2="$( \
            scanelf --needed --nobanner --recursive /py2 \
                    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                    | sort -u \
                    | xargs -r apk info --installed \
                    | sort -u \
    )" \
    && apk add --virtual .python2-rundeps $run_deps_py2 \
    # Python3 setup
    && python3 -m venv --upgrade /py3 \
    && /py3/bin/pip install -U pip \
    && LIBRARY_PATH=/lib:/usr/lib /bin/sh -c "/py3/bin/pip install --no-cache-dir -r /requirements/p3.pip" \
    && run_deps_py3="$( \
            scanelf --needed --nobanner --recursive /py3 \
                    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                    | sort -u \
                    | xargs -r apk info --installed \
                    | sort -u \
    )" \
    && apk add --virtual .python3-rundeps $run_deps_py3 \
    && apk del .build-deps

RUN apk add --no-cache \
    curl \
    bash \
    git \
    mariadb-client

RUN mkdir /code/
WORKDIR /code/fixtureless/tests/test_django_project
COPY . /code/

ENV IN_DOCKER=True PYTHONPATH=$PYTHONPATH:/code/fixtureless/tests/test_django_project/test_django_project
