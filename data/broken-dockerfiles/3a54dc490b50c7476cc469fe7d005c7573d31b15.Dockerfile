FROM elixir:1.4
RUN apt-get update
RUN apt-get install -y inotify-tools
RUN mix local.rebar --force
RUN mix local.hex --force
ADD . /code
WORKDIR /code
RUN mix deps.get
RUN mix compile
CMD mix phx.server
