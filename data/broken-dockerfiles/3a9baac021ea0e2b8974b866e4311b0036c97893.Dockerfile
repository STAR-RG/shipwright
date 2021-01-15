FROM python:3-alpine

RUN apk --update --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
    g++ \
    gcc \
    hdf5-dev \
    libffi-dev \
    libstdc++ \
    musl-dev \
    postgresql-dev \
    python3-dev

RUN pip install pipenv --upgrade

WORKDIR /usr/src/app

COPY Pipfile ./
COPY Pipfile.lock ./

RUN pipenv install --dev --system
