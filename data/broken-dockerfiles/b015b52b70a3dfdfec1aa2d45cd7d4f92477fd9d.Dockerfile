# Basic rDod Image to use for base of any customized one
FROM ubuntu:latest

LABEL maintainer="Matthieu DERASSE <github@derasse.fr>"

# ENV Configuration
ENV DEBIAN_FRONTEND=noninteractive \
    USE_SSL=false \
    RESOLUTION=1920x1080

# Expose our VNC AND HTML VNC server
EXPOSE 5901 5911

# Installing ansible in one step to keep real step in the Build
RUN apt-get update && \
    apt-get install -qq --no-install-recommends -y apt-utils software-properties-common && \
    apt-get install -qq --no-install-recommends -y gnupg dirmngr && \
    apt-add-repository ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -qq -y ansible

# Configure Default System
COPY base /opt/rdod/base

# Launching System Installation
RUN ansible-playbook /opt/rdod/base/install.yml

COPY entrypoint.sh /opt/rdod/launch.sh
RUN chmod +x /opt/rdod/launch.sh && \
    chown -R user:user /var/log/supervisor

USER 1000
WORKDIR /home/user

# Entrypoint
CMD ["/opt/rdod/launch.sh"]
