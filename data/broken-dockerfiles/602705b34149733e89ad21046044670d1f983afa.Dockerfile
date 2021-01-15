FROM quantumobject/docker-baseimage:15.10

# TODO: timezone set

RUN sed 's/main$/main universe multiverse/' -i /etc/apt/sources.list
RUN apt-get update && apt-get -y install python
ADD iRedMail /iRedMail

ADD util/install.sh /iRedMail
ADD util/capture.sh /capture.sh

ARG DOCKER_BUILD_SSL=NO
ARG DOCKER_BUILD_BACKEND=NO
ARG DOCKER_BUILD_IREDADMIN=NO
ARG DOCKER_BUILD_IREDAPD=NO
ARG DOCKER_BUILD_AMAVISD=NO
ARG DOCKER_BUILD_POSTFIX=NO
ARG DOCKER_BUILD_DOVECOT=NO
ARG DOCKER_BUILD_NGINX=NO
ARG DOCKER_BUILD_PHP=NO
ARG IREDMAIL_DEBUG=YES
ARG USE_IREDADMIN=NO
ARG status_check_new_iredmail=DONE
ARG status_cleanup_update_clamav_signatures=DONE
ARG status_cleanup_feedback=DONE

# required build args
ARG HOSTNAME

RUN bash /iRedMail/install.sh

CMD /sbin/my_init

# docker build -t niieani/iredadmin-install-base -f ./docker/install-base/Dockerfile .