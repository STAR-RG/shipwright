ARG PYTHON_VERSION
FROM python:$PYTHON_VERSION-alpine

RUN apk add bash git socat
RUN pip install tox

WORKDIR /src
