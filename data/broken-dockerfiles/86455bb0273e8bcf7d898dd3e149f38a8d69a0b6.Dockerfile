FROM nginx

# Update System
RUN apt-get update
RUN apt-get -y upgrade

# Basic Requirements
RUN apt-get -y install curl git vim

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

# Copy source files
ADD . /tmp/build

WORKDIR /tmp/build

# Build
RUN echo "==== Building Clean Blog ====" && \
    npm install grunt-cli -g && \
    npm install && \
    grunt build

# Move files to serve
COPY dist /usr/share/nginx/html
