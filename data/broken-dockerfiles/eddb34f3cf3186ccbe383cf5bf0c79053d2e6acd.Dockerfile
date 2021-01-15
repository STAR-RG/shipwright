#base-image for node on any machine using a template var
FROM resin/%%RESIN_MACHINE_NAME%%-node

# install native deps
RUN apt-get update && \
    apt-get install -qy \
     wireless-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Defines our working directory in container
WORKDIR /usr/src/app

# Copies the package.json first for better cache on later pushes
COPY package.json package.json

# This install npm dependencies on the resin.io build server,
# making sure to clean up the artifacts it creates in order to reduce the image size.
RUN JOBS=MAX npm install --production --unsafe-perm && npm cache clean && rm -rf /tmp/*

# copy all files to /usr/src/app  dir
COPY . ./

# Enable systemd init system in container
ENV INITSYSTEM=on

# Run server when container runs on device
CMD ["bash", "start.sh"]
