FROM debian:buster AS build
COPY src /src
RUN apt-get update
RUN apt-get upgrade
RUN apt-get install -y build-essential libsqlite3-dev util-linux librsvg2-dev libcairomm-1.0-dev libepoxy-dev libgtkmm-3.0-dev uuid-dev libboost-dev  libzmq5 libzmq3-dev libglm-dev libgit2-dev libcurl4-gnutls-dev liboce-ocaf-dev libpodofo-dev python3-dev libzip-dev git python3-cairo-dev libosmesa6-dev
WORKDIR /src
RUN make -j$(nproc) build/horizon.so
RUN strip build/horizon.so

FROM debian:buster
RUN apt-get update && apt-get upgrade  -y
RUN apt-get install -y --no-install-recommends python3 libzip4 libpython3.7 libglibmm-2.4-1v5 libpodofo0.9.6 liboce-ocaf11 python3-pygit2 git ca-certificates  python3-cairo libosmesa6
COPY --from=build /src/build/horizon.so /usr/local/lib/python3.7/dist-packages
