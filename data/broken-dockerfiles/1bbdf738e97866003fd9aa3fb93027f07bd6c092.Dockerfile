FROM elixir:1.4.1
WORKDIR /app
RUN apt-get update
RUN apt-get install -y npm nodejs nodejs-legacy inotify-tools ruby
ADD . .
RUN mix local.hex --force
RUN mix deps.get
RUN gem install sass
RUN npm cache clean -f; npm install -g n; n stable
RUN npm install
RUN mix local.rebar --force
RUN mix compile
RUN mkdir -p databases
RUN mix test
RUN rm -rf databases/dev
RUN mix setup
EXPOSE 4000
ENV PORT 4000
CMD mix phoenix.server
