FROM python:3.6-alpine

EXPOSE 8000

WORKDIR /app


RUN addgroup -g 10001 app && \
    adduser -D -u 10001 -G app -h /app -s /sbin/nologin app

RUN apk --no-cache add \
    build-base \
    bash \
    curl \
    git \
    openssl-dev \
    libffi-dev \
    py-cffi \
    postgresql \
    postgresql-dev \
    postgresql-client \
    nodejs

COPY requirements.txt /app/requirements.txt
RUN pip install -U pip && \
    pip install -r requirements.txt
# TODO: --require-hashes

COPY package.json /app/package.json
RUN npm install

# Clean up some build packages after we're done with Python.
RUN apk del --purge build-base gcc

# Copy in the whole app after dependencies have been installed & cached.
COPY . /app

# Collect the static assets together, with placeholder env vars.
RUN SECRET_KEY=foo DEBUG=False ALLOWED_HOSTS=localhost \
    DATABASE_URL=postgres://postgres@db/postgres \
    ./manage.py collectstatic --noinput

RUN chown -R app:app /app

# De-escalate from root privileges with app user.
USER app

ENTRYPOINT ["/bin/bash", "/app/bin/run"]
CMD ["dev"]
