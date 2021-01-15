FROM python:3.6-alpine

WORKDIR /build

# ENV defaults
ENV INVOKE_SHELL /bin/ash
ENV USE_VENV false
ENV DJANGO_SETTINGS_MODULE apps.core.settings.docker

# Add required alpine packages
RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
	&& apk add --update git postgresql-dev python-dev gcc musl-dev jpeg-dev zlib-dev gosu && rm -rf /var/cache/apk/* \
	&& adduser -D -u 1002 worker

# Install required python packages
COPY requirements.txt requirements-devel.txt /build/
RUN pip install -r 'requirements-devel.txt'

# Copy app source to docker image
COPY . /build/

RUN invoke static \
	&& chown -R worker /build

# Execute entrypoint script when the container is started
ENTRYPOINT ["/usr/bin/gosu", "worker"]
CMD ["/build/bin/entrypoint.sh"]
EXPOSE 8000
