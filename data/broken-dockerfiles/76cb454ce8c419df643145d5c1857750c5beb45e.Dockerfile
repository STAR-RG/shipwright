FROM python:3.5

MAINTAINER Edu Herraiz <eherraiz@apsl.net>

# ENV NVM_VERSION v0.32.1
# ENV NODE_VERSION 6.9.1
# ENV NVM_DIR /app/.nvm
# Install system requirements
# COPY docker/system-requirements.txt /system-requirements.txt
# RUN  \
#     apt-get update \
#     && apt-get -y upgrade \
#     && apt-get -y autoremove \
#     && xargs apt-get -y -q install < /system-requirements.txt  \
#     && rm -rf /var/lib/apt/lists/*

RUN pip install uwsgi

WORKDIR /app

# Install Nvm and Nodejs
# RUN git clone https://github.com/creationix/nvm.git /app/.nvm -b $NVM_VERSION
# RUN echo $NODE_VERSION > /app/.nvmrc
# COPY package.json /app/package.json
# RUN chmod +x $NVM_DIR/nvm.sh
# RUN \. $NVM_DIR/nvm.sh && nvm install && nvm alias default $NODE_VERSION && npm install

COPY requirements.txt /requirements.txt
# ignore-installed added for this problem with overlay fs: https://github.com/docker/docker/issues/12327
RUN pip install --ignore-installed -r /requirements.txt

COPY docker/uwsgi.ini /uwsgi.ini
COPY server /app

COPY docker/app.ini.docker /app/app.ini
RUN python manage.py collectstatic --noinput

VOLUME /app
VOLUME /data
COPY docker/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["uwsgi"]
EXPOSE 8000 3031