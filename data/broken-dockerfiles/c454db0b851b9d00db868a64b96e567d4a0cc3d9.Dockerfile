FROM phusion/baseimage:0.9.19

# Set basic ENV vars
ENV HOME=/root TERM=xterm-color

# Elixir requires UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8

WORKDIR $HOME

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Install packages needed later
RUN apt-get update && apt-get install -y wget git inotify-tools postgresql-client build-essential

# Download and install Erlang and Elixir
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
  && dpkg -i erlang-solutions_1.0_all.deb \
  && apt-get update \
  && apt-get install -y esl-erlang elixir
RUN rm erlang-solutions*.deb

# Install Node.js
ENV NODE_VERSION_MAJOR=7
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION_MAJOR.x | bash - && apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

# Create app user and set WORKDIR to its home dir
RUN adduser --ingroup staff --disabled-password --gecos "" app
ENV APP_HOME=/home/app
ENV UMBRELLA_ROOT=/home/app/pwr2
RUN mkdir $UMBRELLA_ROOT $UMBRELLA_ROOT/ui
WORKDIR $APP_HOME

# Install Hex, Phoenix and Rebar
RUN setuser app mix local.hex --force
RUN setuser app mix local.rebar --force

# Create Elixir deps and node_modules dirs outside UMBRELLA_ROOT and symlink
# from inside to keep them "safe" when mounting a source volume from HOST
# into UMBRELLA_ROOT.
RUN mkdir $APP_HOME/deps $APP_HOME/node_modules
RUN cd $UMBRELLA_ROOT && ln -s $APP_HOME/deps deps
RUN cd $UMBRELLA_ROOT/ui && ln -s $APP_HOME/node_modules node_modules

# Add app's node_modules to PATH so they can be found by npm
ENV PATH="/home/app/node_modules/.bin:$PATH"

# Copy source code
COPY . $UMBRELLA_ROOT

# Set ownership and permissions
RUN chown -R app:staff /home/app && chmod -R g+s /home/app

# Uninstall some "heavy" packages and clean up apt-get
RUN apt-get remove build-essential -y
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable SSH (Authorized keys must be copied in each specific project/environment)
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

MAINTAINER Iporaitech
