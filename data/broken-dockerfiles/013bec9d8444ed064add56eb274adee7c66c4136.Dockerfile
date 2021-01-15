FROM ubuntu:14.04
MAINTAINER Xabier Larrakoetxea <slok69@gmail.com>

ENV PYTHONUNBUFFERED 1
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# We need the last version of git for the tsuru auto deploy
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:git-core/ppa -y

# System dependencies
RUN apt-get update && \
    apt-get -y install \
        nano \
        python3 \
        python3-dev \
        python3-pip \
        libpq-dev \
        postgresql-client \
        git \
        curl \
        gettext \
        libffi-dev \
        libssl-dev

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
RUN apt-get install -y nodejs

## Python env
RUN pip3 install --upgrade virtualenv
RUN pip3 install --upgrade virtualenvwrapper


# Prepare paths
RUN mkdir -p /app/static
RUN mkdir -p /app/media
RUN mkdir -p /app/node_deps
RUN mkdir /code

# Copy node requirements
WORKDIR /app/node_deps
COPY package.json ./package.json

# Install dependencies
RUN npm install
env PATH="/app/node_deps/node_modules/.bin:$PATH"

# Create the user/group for the running stuff
RUN groupadd -g 1000 wiggum
RUN useradd -m -u 1000 -g 1000 wiggum

# Set permissions
RUN chown wiggum:wiggum -R /app/
RUN chown wiggum:wiggum /code

# Default settings
USER wiggum
WORKDIR /code/wiggum
ENV WORKON_HOME=~/.virtualenvs
ENV VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
RUN echo "source /usr/local/bin/virtualenvwrapper.sh" >> $HOME/.bashrc
RUN echo "workon wiggum" >> $HOME/.bashrc

# Copy python requiremetns
COPY requirements /tmp/wiggum_requirements

# virtualenv
RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh \
    && mkvirtualenv wiggum \
    && workon wiggum \
    && pip install pudb \
    && pip install -r /tmp/wiggum_requirements/dev.txt"


CMD ["run.sh"]
