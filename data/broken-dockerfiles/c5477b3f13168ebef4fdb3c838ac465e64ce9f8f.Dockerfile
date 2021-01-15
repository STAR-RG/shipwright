FROM astrocoders/esy:0.5.6

RUN apt-get update
RUN apt-get install -y libpq-dev

COPY . /workspace
WORKDIR /workspace

EXPOSE 3000

RUN esy i
RUN esy b
RUN npx knex migrate:latest

ENTRYPOINT ["esy", "x", "Server.exe"]
