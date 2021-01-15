FROM resin/%%RESIN_MACHINE_NAME%%-buildpack-deps

# Enable systemd, as Resin requires this
ENV INITSYSTEM on

# Make the hardware type available as a runtime env var
ENV RESIN_ARCH %%RESIN_ARCH%%
ENV RESIN_MACHINE_NAME %%RESIN_MACHINE_NAME%%

# Version number of gateway software.
# (Incrementing this simply forces Docker to flush its cache
#  and thus forces a full rebuild. Not used outside of Dockerfile.)
ENV TTN_GATEWAY_SOFTWARE 51

# Copy the build and run environment
COPY . /opt/ttn-gateway/
WORKDIR /opt/ttn-gateway/

# Build the gateway (or comment this out if debugging on-device)
RUN ./dev/build.sh && rm -rf ./dev

# Start it up
CMD ["sh", "-c", "./run.sh"]
