FROM centos:7

ENTRYPOINT ["/opt/gogs/start.sh"]

ENV VERSION=0.9.97

RUN yum install -y --setopt=tsflags=nodocs epel-release && \
    yum install -y --setopt=tsflags=nodocs nss_wrapper gettext sqlite git && \
    yum clean all

RUN cd /opt && \
    curl -L https://cdn.gogs.io/gogs_v${VERSION}_linux_amd64.tar.gz | tar xzv

COPY passwd.template /tmp/passwd.template
COPY start.sh /opt/gogs/start.sh

COPY build/ssh-hostkeygen build/start-gogs /opt/gogs/
COPY build/ssh-keygen /usr/bin/ssh-keygen

RUN mkdir -p /app/gogs/data /opt/gogs/custom/conf && chmod 777 /app/gogs/data /opt/gogs/custom /opt/gogs/custom/conf

USER 10000

ENV HOME=/app/gogs/data \
    PATH=/app/gogs:$PATH \
    ADMIN_USER_CREATE=true \
    ADMIN_USER_NAME=gogsadmin \
    ADMIN_USER_EMAIL=gogsadmin@fabric8.local \
    ADMIN_USER_PASSWORD=admin123 \
    GOGS_SECURITY__INSTALL_LOCK=true \
    GOGS_RUN_USER=git \
    GOGS_RUN_MODE=prod \
    GOGS_REPOSITORY__ROOT=/app/gogs/data/repositories \
    GOGS_SERVER__START_SSH_SERVER=true \
    GOGS_SERVER__SSH_PORT=2222 \
    GOGS_SERVER__SSH_ROOT_PATH=/app/gogs/data/git/.ssh \
    GOGS_SERVER__APP_DATA_PATH=/app/gogs/data \
    GOGS_DATABASE__DB_TYPE=sqlite3 \
    GOGS_DATABASE__PATH=/app/gogs/data/gogs.db \
    GOGS_SERVICE__ENABLE_REVERSE_PROXY_AUTHENTICATION=true \
    GOGS_SERVICE__ENABLE_REVERSE_PROXY_AUTO_REGISTRATION=true \
    GOGS_SESSION__PROVIDER_CONFIG=/app/gogs/data/sessions \
    GOGS_PICTURE__AVATAR_UPLOAD_PATH=/app/gogs/data/avatars \
    GOGS_ATTACHMENT__PATH=/app/gogs/data/attachments \
    GOGS_LOG__ROOT_PATH=/app/gogs/data/logs \
    GOGS_LOG__LEVEL=Error
