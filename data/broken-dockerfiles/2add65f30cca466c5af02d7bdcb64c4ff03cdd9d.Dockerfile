FROM google/dart:2.4.0
WORKDIR /build/

# Build Environment Vars
ARG BUILD_ID
ARG BUILD_NUMBER
ARG BUILD_URL
ARG GIT_COMMIT
ARG GIT_BRANCH
ARG GIT_TAG
ARG GIT_COMMIT_RANGE
ARG GIT_HEAD_URL
ARG GIT_MERGE_HEAD
ARG GIT_MERGE_BRANCH
# Expose env vars for git ssh access
ARG GIT_SSH_KEY
ARG KNOWN_HOSTS_CONTENT

# Install SSH keys for git ssh access
RUN mkdir /root/.ssh
RUN echo "$KNOWN_HOSTS_CONTENT" > "/root/.ssh/known_hosts"
RUN echo "$GIT_SSH_KEY" > "/root/.ssh/id_rsa"
RUN chmod 700 /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa

RUN pub global activate --hosted-url https://pub.workiva.org semver_audit ^2.0.1

COPY pubspec.yaml ./
RUN pub get

ADD ./ ./

RUN pub global run semver_audit report --repo Workiva/json_schema

ARG BUILD_ARTIFACTS_BUILD=/build/pubspec.lock
FROM scratch
