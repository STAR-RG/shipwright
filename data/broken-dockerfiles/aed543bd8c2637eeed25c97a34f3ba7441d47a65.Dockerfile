# f5-ansible - Dockerfile
# https://github.com/ArtiomL/f5-ansible
# Artiom Lichtenstein
# v1.0.7, 19/09/2018

FROM alpine

LABEL maintainer="Artiom Lichtenstein" version="1.0.7"

# Core dependencies
RUN apk add --update --no-cache ansible git && \
	pip3 install --no-cache-dir --upgrade pip && \
	pip3 install --no-cache-dir bigsuds deepdiff f5-sdk netaddr yamllint && \
	pip3 uninstall -y pip setuptools && \
	rm -rf /var/cache/apk/*

# Ansible
COPY / /opt/ansible/
WORKDIR /opt/ansible/

# System account and permissions
RUN adduser -u 1001 -D user
RUN chown -RL user: /opt/ansible/
RUN chmod +x runsible.py scripts/start.sh

# UID to use when running the image and for CMD
USER 1001

# Run
CMD ["scripts/start.sh"]
