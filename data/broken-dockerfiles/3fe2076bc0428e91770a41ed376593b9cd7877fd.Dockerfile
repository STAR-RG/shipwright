# Step 1: Get dependencies
FROM elixir:1.5.2 as asset-builder-mix-getter

ENV HOME=/opt/app

RUN mix do local.hex --force, local.rebar --force
# Cache elixir deps
COPY config/ $HOME/config/
COPY mix.exs mix.lock $HOME/

WORKDIR $HOME
RUN mix deps.get

########################################################################
# Step 2: Build node assets
FROM node:6 as asset-builder

ENV HOME=/opt/app
WORKDIR $HOME

COPY --from=asset-builder-mix-getter $HOME/deps $HOME/deps

WORKDIR $HOME/assets
COPY assets/ ./
RUN npm install
RUN ./node_modules/.bin/brunch build --production

########################################################################
# Step 3: Build elixir release
FROM bitwalker/alpine-elixir:1.5.2 as releaser

ENV HOME=/opt/app

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# Cache elixir deps
COPY config/ $HOME/config/
COPY mix.exs mix.lock $HOME/

ENV MIX_ENV=prod
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY . $HOME/

# Digest precompiled assets
COPY --from=asset-builder $HOME/priv/static/ $HOME/priv/static/

WORKDIR $HOME
RUN mix phx.digest
RUN mix release --env=$MIX_ENV --verbose
RUN mv $HOME/_build/prod/rel/*/releases/*/*.tar.gz $HOME/app.tar.gz

########################################################################
# Step 4: Get minimal container with elixir release
FROM alpine:3.6

ENV LANG=en_US.UTF-8 HOME=/opt/app/ TERM=xterm

RUN apk add --no-cache bash openssl

EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod REPLACE_OS_VARS=true SHELL=/bin/sh

COPY --from=releaser $HOME/app.tar.gz $HOME
WORKDIR $HOME
RUN tar -xzf app.tar.gz

ENTRYPOINT ["/opt/app/bin/pricey"]
CMD ["foreground"]
