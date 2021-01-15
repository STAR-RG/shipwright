FROM openjdk:8-slim
MAINTAINER Julian Xhokaxhiu <info at julianxhokaxhiu dot com>

# Environment variables
#######################

ENV USER root
ENV SRC_DIR /srv/src
ENV CCACHE_DIR /srv/ccache
ENV ZIP_DIR /srv/zips
ENV LMANIFEST_DIR /srv/local_manifests

# Configurable environment variables
####################################

# By default we want to use CCACHE, you can disable this
# WARNING: disabling this may slow down a lot your builds!
ENV USE_CCACHE 1

# Environment that controls the CCACHE size
# suggested: 50G
ENV CCACHE_SIZE '50G'

# Environment that compresses objects stored in CCACHE
# suggested: 1
# WARNING: While this may involve a tiny performance slowdown, it increases the number of files that fit in the cache.
ENV CCACHE_COMPRESS 1

# Environment for the LineageOS Branch name
# See https://github.com/LineageOS/android_vendor_cm/branches for possible options
ENV BRANCH_NAME 'cm-14.1'

# Environment for the device list ( separate by comma if more than one)
# eg. DEVICE_LIST=hammerhead,bullhead,angler
ENV DEVICE_LIST ''

# OTA build.prop key that will be used inside CMUpdater
# Use this in combination with LineageOTA to make sure your device can auto-update itself from this buildbot
ENV OTA_PROP 'cm.updater.uri'

# OTA URL that will be used inside CMUpdater
# Use this in combination with LineageOTA to make sure your device can auto-update itself from this buildbot
ENV OTA_URL ''

# User identity
ENV USER_NAME 'LineageOS Buildbot'
ENV USER_MAIL 'lineageos-buildbot@docker.host'

# If you want to start always fresh ( re-download all the source code everytime ) set this to 'true'
ENV CLEAN_SRCDIR false

# If you want to preserve old ZIPs set this to 'false'
ENV CLEAN_OUTDIR true

# Change this cron rule to what fits best for you
# By Default = At 10:00 UTC ~ 2am PST/PDT
ENV CRONTAB_TIME '0 10 * * *'

# Print detailed output rather than only summary
ENV DEBUG false

# Clean artifacts output after each build
ENV CLEAN_AFTER_BUILD true

# Provide root capabilities builtin inside the ROM ( see http://lineageos.org/Update-and-Build-Prep/ )
ENV WITH_SU true

# Provide a default JACK configuration in order to avoid out-of-memory issues
ENV ANDROID_JACK_VM_ARGS "-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G"

# Create Volume entry points
############################

VOLUME $SRC_DIR
VOLUME $CCACHE_DIR
VOLUME $ZIP_DIR
VOLUME $LMANIFEST_DIR

# Copy required files and fix permissions
#####################

COPY src/* /root/

# Create missing directories
############################

RUN mkdir -p $SRC_DIR
RUN mkdir -p $CCACHE_DIR
RUN mkdir -p $ZIP_DIR
RUN mkdir -p $LMANIFEST_DIR

# Set the work directory
########################

WORKDIR $SRC_DIR

# Fix permissions
#################

RUN chmod 0755 /root/*

# Enable contrib support
#########################

RUN sed -i "s/ main$/ main contrib/" /etc/apt/sources.list

# Install required Android AOSP packages
########################################

RUN apt-get update && apt-get install -y --no-install-recommends \
    bc \
    bison \
    build-essential \
    ccache \
    cron \
    curl \
    flex \
    g++-multilib \
    gcc-multilib \
    git \
    gnupg \
    gperf \
    imagemagick \
    lib32ncurses5-dev \
    lib32readline-dev \
    lib32z1-dev \
    libesd0-dev \
    liblz4-tool \
    libncurses5-dev \
    libsdl1.2-dev \
    libssl-dev \
    libwxgtk3.0-dev \
    libxml2 \
    libxml2-utils \
    lzop \
    maven \
    openssl \
    pngcrush \
    procps \
    python \
    repo \
    rsync \
    schedtool \
    squashfs-tools \
    unzip \
    wget \
    xsltproc \
    zip \
    zlib1g-dev

# Allow redirection of stdout to docker logs
############################################
RUN ln -sf /proc/1/fd/1 /var/log/docker.log

# Cleanup
#########

RUN apt-get clean && apt-get autoclean

# Set the entry point to init.sh
###########################################

ENTRYPOINT /root/init.sh