FROM ocaml/opam2:alpine-3.7 as build

ENV OPAMYES=1

RUN opam pin add crowbar --dev -n
RUN opam install opam-depext
RUN opam depext -i jbuilder fmt logs lwt menhir higher ppx_deriving \
      crowbar ocaml-protoc \
      mirage-runtime mirage-block-lwt mirage-stack-lwt mirage-unix \
      mirage-net-unix tcpip mirage-clock-unix mirage-block-unix \
      mirage-logs

COPY . /src
RUN sudo chown -R opam /src
WORKDIR /src

RUN opam exec -- jbuilder build mirage/main.exe

FROM scratch

COPY --from=build /src/_build/default/mirage/main.exe /app
ENTRYPOINT ["/app"]
