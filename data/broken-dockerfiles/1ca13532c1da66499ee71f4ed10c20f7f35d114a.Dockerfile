# Based on https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-rhel-atomic/Dockerfile
FROM registry.centos.org/centos/centos7-atomic:latest
MAINTAINER Citellus developers <citellus _AT_ googlegroups.com>

LABEL name="citellus/citellus" \
      maintainer="citellus _AT_ googlegroups.com.com" \
      vendor="Citellus" \
      version="1.0.0" \
      release="1" \
      summary="System configuration validation program" \
      description="Citellus is a program that should help with system configuration validation on either live system or any sort of snapshot of the filesystem."

ENV USER_NAME=citellus \
    USER_UID=10001

# Required for useradd command and pip
RUN PRERREQ_PKGS="shadow-utils \
      libsemanage \
      ustr \
      audit-libs \
      libcap-ng \
      epel-release" && \
    REQ_PKGS="bc \
      python-pip" && \
    microdnf install --nodocs ${PRERREQ_PKGS} && \
    microdnf install --nodocs ${REQ_PKGS} && \
    useradd -l -u ${USER_UID} -r -g 0 -s /sbin/nologin \
      -c "${USER_NAME} application user" ${USER_NAME} && \
    microdnf remove ${PRERREQ_PKGS} && \
    microdnf clean all

RUN pip install --upgrade pip --no-cache-dir && \
    pip install --upgrade pbr --no-cache-dir && \
    pip install --upgrade citellus --no-cache-dir && \
    mkdir -p /data && \
    chmod -R u+x /data && \
    chown -R ${USER_UID}:0 /data && \
    chmod -R g=u /data

USER 10001
VOLUME /data
ENTRYPOINT ["/usr/bin/citellus.py"]
CMD ["-h"]
