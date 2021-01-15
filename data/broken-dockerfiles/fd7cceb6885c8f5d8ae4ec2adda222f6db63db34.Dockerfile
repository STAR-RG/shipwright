FROM ubuntu:xenial

RUN apt-get update && apt-get install --yes nginx

# Set git commit ID
ARG COMMIT_ID
RUN test -n "${COMMIT_ID}"

# Copy over files
WORKDIR /srv
ADD _site .
ADD nginx.conf /etc/nginx/sites-enabled/default
RUN sed -i "s/~COMMIT_ID~/${COMMIT_ID}/" /etc/nginx/sites-enabled/default

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

