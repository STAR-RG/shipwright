FROM danielquinn/django:alpine

RUN set -ex && mkdir /app

COPY Pipfile /app/Pipfile
COPY Pipfile.lock /app/Pipfile.lock

WORKDIR /app

RUN apk add --update --no-cache postgresql-client git \
  && apk add --virtual .build-deps gcc g++ postgresql-dev \
  && set -ex && pipenv install --deploy --system \
  && apk del .build-deps \
  && rm /var/cache/apk/*
