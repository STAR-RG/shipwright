FROM elixir:1.7.3

RUN mix local.hex --force, mix local.rebar --force

COPY . /app

WORKDIR /app

RUN mix do deps.get, compile

CMD iex -S mix phx.server
