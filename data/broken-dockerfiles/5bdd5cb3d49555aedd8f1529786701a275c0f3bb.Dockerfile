FROM php:7.1-cli

LABEL maintainer "Marc Siebeneicher <marc.siebeneicher@trivago.com>"
LABEL version="dev-master"
LABEL description="chronos & marathon console client - Manage your jobs like a git repository"

# Install depencies
RUN apt-get update \
    && apt-get install --no-install-recommends -y git zip unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -k https://getcomposer.org/composer.phar > /usr/bin/composer && \
  chmod +x /usr/bin/composer

# Copy code
COPY . /chapi

# create symlink
RUN ln -s /chapi/bin/chapi /usr/local/bin/chapi

# Install chapi
WORKDIR /chapi
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Configuration
RUN mkdir /root/.chapi

# Set ENTRYPOINT
ENTRYPOINT ["bin/chapi"]