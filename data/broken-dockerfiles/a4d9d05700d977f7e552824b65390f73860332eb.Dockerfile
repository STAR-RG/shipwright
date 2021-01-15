FROM heroku/cedar:14
MAINTAINER Gabriel Berke-Williams <gabe@thoughtbot.com>

ENV LANG en_US.UTF-8
# Stack stores binaries in /root/.local/bin
ENV PATH /root/.local/bin:$PATH

# Heroku assumes we'll put everything in /app/user
RUN mkdir -p /app/user
WORKDIR /app/user

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 575159689BEFB442 \
  && echo 'deb http://download.fpcomplete.com/ubuntu trusty main' > \
    /etc/apt/sources.list.d/fpco.list \
  && apt-get update \
  && apt-get install -y stack \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Preinstall GHC using Stack
ENV STACK_LTS_VERSION 6.3
RUN stack setup --resolver lts-$STACK_LTS_VERSION

# Install application framework in a separate layer for caching
ONBUILD COPY ./stack-bootstrap .
ONBUILD RUN stack install \
  --resolver lts-$STACK_LTS_VERSION \
  $(cat stack-bootstrap)

# Copy over configuration for building the app
ONBUILD COPY stack.yaml .
ONBUILD COPY *.cabal .

# Build dependencies so that if we change something later we'll have a Docker
# cache of up to this point.
ONBUILD RUN stack build --dependencies-only

ONBUILD COPY . /app/user

# Run pre-build script if it exists (compile CSS, etc)
ONBUILD RUN if [ -x bin/pre-build ]; then bin/pre-build; fi

# Build and copy the executables into the app
ONBUILD RUN stack --local-bin-path=. install

# Clean up
ONBUILD RUN rm -rf /app/user/.stack-work
