# This Dockerfile supports the bin/test script for local testing.
# Make sure any changes here stay in sync with .circleci/config.yml
# so local testing and CI are comparable.

ARG PYTHON_VERSION=3.6
FROM python:$PYTHON_VERSION

RUN apt-get update && apt-get install -y libsnappy-dev openjdk-8-jre-headless
RUN pip install tox

WORKDIR /python_moztelemetry

# Copy the current directory as is to the workdir;
# Relies on the .dockerignore file to prune out large files we don't want to include.
COPY . .
