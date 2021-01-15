ARG MOPIDY_XTRAS_PARENT_IMAGE="trevorj/boilerplate"
ARG MOPIDY_XTRAS_PARENT_TAG="latest"
FROM $MOPIDY_XTRAS_PARENT_IMAGE:$MOPIDY_XTRAS_PARENT_TAG

MAINTAINER Trevor Joynson <docker@trevor.joynson.io>

COPY requirements/base.* requirements/
RUN install-reqs requirements/base.*

RUN set -exv \
 && curl -sSLf https://apt.mopidy.com/mopidy.gpg \
    | apt-key add - \
 && lazy-apt-repo mopidy https://apt.mopidy.com/mopidy.list \
 && ensure-apt-lists \
 && lazy-apt --no-install-recommends \
    $(apt-cache search '^mopidy-.*' | sed -e 's/ .*$//' | egrep -v 'gpodder|doc') \
 && :

COPY requirements/install.* requirements/
RUN lazy-apt-with --no-install-recommends \
    build-essential \
    python-dev python-pip python-wheel \
    libssl-dev \
    libffi-dev \
    libgmp-dev \
 -- install-reqs requirements/install.pip

COPY image image

USER $APP_USER

ENV PULSE_SERVER="tcp:localhost:4713" \
    PULSE_COOKIE_DATA="" \
    PULSE_COOKIE="" \
    XDG_CONFIG_HOME="$APP_ROOT/.config" \
    XDG_CACHE_HOME="$APP_ROOT/.cache" \
    XDG_DATA_HOME="$APP_ROOT/.local/share" \
    XDG_MUSIC_DIR="$APP_ROOT/Music" \
    #XDG_RUNTIME_DIR="/run/user/1000" \
    APP_UID=1000

VOLUME $XDG_DATA_HOME/mopidy $XDG_CONFIG_HOME

EXPOSE 6600 6680
CMD ["mopidy"]

ADD run docker-compose.yml README.md ./host/

# delevate down to $APP_USER in entrypoint after fixing up perms
USER root

# Healthcheck on the HTTP port
# Disabled: Fucking Circle is so out of date. Ugh.
#HEALTHCHECK --interval=5m --timeout=3s CMD curl -sSLf http://localhost:6680
