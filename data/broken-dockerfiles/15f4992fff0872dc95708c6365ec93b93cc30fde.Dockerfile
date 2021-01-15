# see more about dockerfile templates here: http://docs.resin.io/deployment/docker-templates/
# and about resin base images here: http://docs.resin.io/runtime/resin-base-images/
FROM resin/%%RESIN_MACHINE_NAME%%-debian

# install required packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
    bluez \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# define our working directory in the container
WORKDIR usr/src/app

# copy all files in our root to the working directory
COPY . ./

# enable systemd init system in the container
ENV INITSYSTEM on

# scan.sh will run when the container starts up on the device
CMD ["bash", "scan.sh"]
