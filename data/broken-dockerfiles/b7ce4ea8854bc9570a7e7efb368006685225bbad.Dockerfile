FROM quay.io/continuouspipe/symfony-php7.1-nginx:stable

# Set Symfony environment inside a container. Default is `prod`.
# This only has an effect on the build phase and `bin/console`
# commands run from inside the container. Front controllers
# `/app.php`, `/app_dev.php` and `/app_test.php` will still use
# appropriate environments despite the option you provide here.
ARG SYMFONY_ENV=dev
# Enforce development mode of `container build`. Default is `false`.
# This primarily controls `composer install` flags. When this is
# set to `false` `--no-dev` flag would be added to `composer
# install`, making it ignore all the dev dependencies. Useful
# option in production, but hindering in development.
ARG DEVELOPMENT_MODE=true
# Here we propagate build-level environment variable to a container
# level one. `ARG` sets environment variables available only during
# the container build phase. `ENV` sets environment variables
# available only inside the built container itself. This setting
# right here makes Symfony environment inside the built container
# to be exactly the same as the one used while building it.
ENV SYMFONY_ENV $SYMFONY_ENV
# This enables/disables `/app_dev.php` and `/app_test.php` front
# controllers. Default is `false`.
ENV SYLIUS_APP_DEV_PERMITTED true

# Install NodeJS and NPM to allow assets building.
# Sylius uses `Gulp` for asset building. `Gulp` is installed using
# `npm` and `npm` requires `nodejs`.
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    nodejs \
    npm \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /usr/bin/nodejs /usr/bin/node

# Set up the default timezone for PHP.
# `php-nginx` sets timezone for FPM configuration, but not CLI.
# This ensures PHP CLI inside container have timezone set too.
RUN echo "date.timezone = UTC" >> /etc/php/7.0/cli/conf.d/docker.ini

# Copy the entire current directory into container's `/app`.
COPY . /app/
# Make container's `/app` directory a working directory.
WORKDIR /app
# Remove Symfony cache and logs.
# As we copied the entire `/app` directory previously, it
# potentially came with the local system cache and logs. We
# obviously don't care for it, so we wipe `var/cache` clean.
RUN rm -rf var/cache/* var/logs/*

# Build web-server, permissions, dependencies and app itself.
# This command is provided by `php-nginx` container and
# extended by `symfony-php-nginx`.
RUN container build
# Install node dependencies.
# Those primarily are related to the asset pipeline.
RUN npm install

# Rebuild autoloader without optimisation.
# `php-nginx` container when executes `container build`
# uses `--optimise` flag. This flag speeds up autoloading
# in `prod` environment, but breaks application in multiple
# places in `dev` environment. This line isn't necessary
# for `prod` containers.
RUN composer --no-interaction dump-autoload
# Wipe the cache and logs after all the build activities.
# We want this container to be clean slate for a server,
# hence we wipe the cache and logs folders.
RUN rm -rf var/cache/* var/logs/*
