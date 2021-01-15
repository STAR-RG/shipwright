FROM golang:1.12-stretch AS tf-builder
ARG GITHUB_TOKEN
ARG BUCKET
ARG AWS_CONTAINER_CREDENTIALS_RELATIVE_URI
ARG AWS_EXECUTION_ENV
ARG AWS_DEFAULT_REGION
ARG AWS_REGION
ARG CLI_PROFILE

ENV GITHUB_TOKEN=${GITHUB_TOKEN} BUCKET=${BUCKET} \
  AWS_CONTAINER_CREDENTIALS_RELATIVE_URI=${AWS_CONTAINER_CREDENTIALS_RELATIVE_URI} \
  AWS_EXECUTION_ENV=${AWS_EXECUTION_ENV} AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
  AWS_REGION=${AWS_REGION} CLI_PROFILE=${CLI_PROFILE}

SHELL ["/bin/bash", "-c"]
WORKDIR /app

RUN apt-get update && apt-get install -y zip && rm -rf /var/cache/apt

RUN go mod init github.com/jeshan/tfbridge

COPY tfbridge/lambda tfbridge/lambda
COPY tfbridge/crud tfbridge/crud
#COPY tfbridge/real-tests tfbridge/real-tests
COPY tfbridge/utils tfbridge/utils

RUN go build -o dist/main tfbridge/lambda/main.go

COPY tfbridge/release tfbridge/release
COPY .git .git
RUN git describe --tags `git rev-list --tags --max-count=1` > .current-version
RUN go build -o dist/create-release tfbridge/release/main/create-release.go
RUN go build -o dist/write-build-info tfbridge/release/main/main.go
COPY *.gohtml ./

COPY tfbridge/providers tfbridge/providers

RUN dist/write-build-info

COPY build-plugins.sh ./
RUN time ./build-plugins.sh

FROM python:3-slim
RUN pip install awscli aws-sam-cli
WORKDIR /app

COPY --from=0 /app/.version /app/go.mod /app/*.gohtml /app/download-dependencies.txt ./
COPY --from=0 /app/dist/ dist/
COPY --from=0 /app/tfbridge/providers tfbridge/providers

COPY deploy-artefacts.sh ./
COPY templates templates
COPY config config

ARG GITHUB_TOKEN
ARG BUCKET
ARG AWS_CONTAINER_CREDENTIALS_RELATIVE_URI
ARG AWS_EXECUTION_ENV
ARG AWS_DEFAULT_REGION
ARG AWS_REGION
ARG CLI_PROFILE

ENV GITHUB_TOKEN=${GITHUB_TOKEN} BUCKET=${BUCKET} \
  AWS_CONTAINER_CREDENTIALS_RELATIVE_URI=${AWS_CONTAINER_CREDENTIALS_RELATIVE_URI} \
  AWS_EXECUTION_ENV=${AWS_EXECUTION_ENV} AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
  AWS_REGION=${AWS_REGION} CLI_PROFILE=${CLI_PROFILE}


ENV LC_ALL=C.UTF-8 LANG=C.UTF-8
RUN AWS_REGION=${AWS_REGION} AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} BUCKET=${BUCKET} CLI_PROFILE=${CLI_PROFILE} ./deploy-artefacts.sh
RUN dist/create-release
