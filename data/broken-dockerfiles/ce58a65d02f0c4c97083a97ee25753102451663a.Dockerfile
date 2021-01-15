FROM bitwalker/alpine-erlang

ARG APP

EXPOSE 5000
EXPOSE 4369
ENV PORT=5000 \
    MIX_ENV=prod

WORKDIR ${HOME}

COPY releases releases
RUN \
    mkdir -p /opt/$APP/log && \
    cp releases/$APP.tar.gz /opt/$APP && \
    cd /opt/$APP && \
    tar -xzf $APP.tar.gz && \
    rm $APP.tar.gz && \
    rm -rf /opt/app/* && \
    chmod -R 777 /opt/app && \
    chmod -R 777 /opt/$APP && \
    ln -s /opt/$APP/bin/$APP /opt/$APP/bin/app

WORKDIR /opt/$APP

COPY bin/run run

CMD ./run foreground
