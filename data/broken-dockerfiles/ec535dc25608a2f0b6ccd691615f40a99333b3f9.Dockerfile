FROM bitwalker/alpine-elixir:1.7.3

RUN apk update
RUN apk --no-cache --update upgrade musl 
RUN apk --no-cache --update add make \ 
                                gcc \ 
                                g++ \ 
                                clang \ 
                                libsodium \
                                libsodium-dev \
                                musl-dev \
                                rust \
                                cargo \
                                linux-headers

RUN rm -rf /var/cache/apk/*
ADD . /opt/app
WORKDIR /opt/app
ENV MIX_ENV=prod

RUN rm -rf _build
RUN rm -rf deps
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

RUN mix deps.get --only-prod
RUN mix release --env=prod --verbose .

FROM bitwalker/alpine-elixir:1.7.3
ENV MIX_ENV=prod

WORKDIR /opt/app
COPY --from=0 /opt/app/_build/prod/rel/purple_node .

RUN apk update
RUN apk --no-cache --update add bash
RUN rm -rf /var/cache/apk/*

EXPOSE 44034

ADD run.sh .
RUN chmod +x run.sh

CMD ["./run.sh"]