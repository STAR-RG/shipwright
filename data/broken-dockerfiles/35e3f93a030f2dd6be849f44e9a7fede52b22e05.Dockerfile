FROM python:3.7-slim
ENV PYTHONDONTWRITEBYTECODE 1

EXPOSE 8000

RUN useradd --uid 1000 --no-create-home --home-dir /app webdev

RUN mkdir -p \
        /usr/share/man/man1 \
        /usr/share/man/man2 \
        /usr/share/man/man3 \
        /usr/share/man/man4 \
        /usr/share/man/man5 \
        /usr/share/man/man6 \
        /usr/share/man/man7 \
        /usr/share/man/man8 && \
    apt-get update && \
    apt-get install -y --no-install-recommends build-essential libpq-dev \
      mime-support postgresql-client gettext curl netcat && \
      apt-get autoremove -y && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Using PIL or Pillow? You probably want to uncomment next line
# RUN apt-get update && apt-get install -y --no-install-recommends libjpeg8-dev

WORKDIR /app

# First copy requirements so we can take advantage of docker caching.
COPY requirements/*.txt /app/
RUN pip install --require-hashes --no-cache-dir -r all.txt

COPY . /app
RUN chown webdev:webdev -R .
USER webdev

RUN DEBUG=False SECRET_KEY=foo ALLOWED_HOSTS=localhost, PRESTO_URL=foo DATABASE_URL=sqlite:// ./manage.py collectstatic --noinput -c

# Generate gzipped versions of files that would benefit from compression, that
# WhiteNoise can then serve in preference to the originals. This is required
# since WhiteNoise's Django storage backend only gzips assets handled by
# collectstatic, and so does not affect files in the `dist/` directory.
RUN python -m whitenoise.compress dist

# Using /bin/bash as the entrypoint works around some volume mount issues on Windows
# where volume-mounted files do not have execute bits set.
# https://github.com/docker/compose/issues/2301#issuecomment-154450785 has additional background.
ENTRYPOINT ["/bin/bash", "/app/bin/run"]

CMD ["web"]
