FROM meteorhacks/meteord:onbuild

RUN apt-get update \
&&  apt-get install -yq mongodb-clients \
&&  rm -rf /var/lib/apt/lists/*

