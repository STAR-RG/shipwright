# BUILD
FROM elixir:1.9.4-alpine as build

RUN apk add --no-cache --update make g++ nodejs npm

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV prod

WORKDIR /app

COPY . .

RUN mkdir /secrets
COPY config/dummy-credentials.json /secrets/dummy-credentials.json

RUN mix deps.get --only prod && npm run deploy --prefix ./assets && mix phx.digest && mix release --quiet

# RELEASE
FROM alpine:3.10.3

RUN apk add --no-cache --update bash

RUN mkdir /secrets
COPY --from=build /secrets/dummy-credentials.json /secrets/dummy-credentials.json
WORKDIR /app

COPY --from=build /app/_build/prod/rel/postoffice ./

CMD ["start"]
ENTRYPOINT ["/app/bin/postoffice"]