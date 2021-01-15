FROM opensuse:latest

# Make sure we do not spend time preparing the OS
# while the installation sources are not mounted.
RUN test -f /var/tmp/ABAP_Trial/install.sh

# General information
LABEL de.itsfullofstars.sapnwdocker.version="1.0.0-filak-sap-2"
LABEL de.itsfullofstars.sapnwdocker.vendor="Tobias Hofmann"
LABEL de.itsfullofstars.sapnwdocker.name="Docker for SAP NetWeaver 7.5x Developer Edition"
LABEL modified_by="Jakub Filak <jakub.filak@sap.com>"

LABEL flags_run="docker run -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro --privileged -p 3200:3200 -p 3300:3300 -p 8000:8000 -p 44300:44300 -h vhcalnplci --name abaptrial"
LABEL installation_size="50"
LABEL thinpool_size="80"
LABEL base_size="65"
LABEL memory="4GB"

LABEL sid="npl"
LABEL dbpassword="S3cr3tP@ssw0rd"
LABEL sapusers="DDIC,SAP*,DEVELOPER"
LABEL sappassword="Down1oad"

ENV container docker

# Install dependencies and configure systemd to start only the services we
# need!
RUN zypper refresh -y; zypper dup -y; \
zypper --non-interactive install --replacefiles  systemd uuidd expect tcsh which iputils vim hostname tar net-tools iproute2 curl python-openssl python-pip; \
zypper clean; \
(cd /usr/lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /usr/lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /usr/lib/systemd/system/local-fs.target.wants/*; \
rm -f /usr/lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /usr/lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /usr/lib/systemd/system/basic.target.wants/*;\
rm -f /usr/lib/systemd/system/anaconda.target.wants/*;

# We need to start the container with cgroups:
# $ docker run -v /sys/fs/cgroup:/sys/fs/cgroup:ro ...
VOLUME [ "/sys/fs/cgroup" ]

# Wrap the command startsap in a systemd service, so we do not need to log in
# to the container and start it manually.
COPY nwabap.service /etc/systemd/system

# Avoid the need to start uuidd manually.
# BTW, uuidd is not needed for the installation.
RUN systemctl enable nwabap uuidd

# Copy trusted server certificates
RUN mkdir -p /etc/pki/ca-trust/source/SAP
COPY files/certs/*.cer /etc/pki/ca-trust/source/SAP/

# Install PyRFC
RUN pip install --upgrade pip
RUN cd /var/tmp && curl -LO https://github.com/SAP/PyRFC/raw/master/dist/pyrfc-1.9.93-cp27-cp27mu-linux_x86_64.whl && \
    pip install /var/tmp/pyrfc-1.9.93-cp27-cp27mu-linux_x86_64.whl && rm -f /var/tmp/pyrfc-1.9.93-cp27-cp27mu-linux_x86_64.whl

# Install the utility for adding trusted certs over RFC
COPY utils/src/sap_add_trusted_server_cert /usr/local/bin

# Add the installer expect
COPY utils/src/install.expect /usr/local/bin

RUN mkdir /usr/local/bin/mock
COPY utils/src/mock/sysctl /usr/local/bin/mock

# HOSTNAME is imbued into SAP stuff - so we must convince the installer
# to use the well known HOSTNAME.
# And we have to try really hard, so don't forget to start docker build with:
#
# -v $PWD/mock_hostname/ld.so.preload
# -v $PWD/mock_hostname/libmockhostname.so:/usr/local/lib64/libmockhostname.so
#
# In case you want to know what the library does:
#   https://github.com/jfilak/snippets/tree/master/mock_hostname
#
# Note: Password being used is S3cr3tP@ssw0rd
RUN  echo $(grep $(uname -n) /etc/hosts | cut -f1 -d$'\t')  "vhcalnplci" >> /etc/hosts; \
     export HOSTNAME="vhcalnplci"; \
     echo $HOSTNAME > /etc/hostname; \
     echo "export HOSTNAME=$HOSTNAME" >> /etc/profile; \
     test $(hostname) == $HOSTNAME || exit 1; \
     export SAP_LOG_FILE="/var/tmp/abap_trial_install.log"; \
     export PATH=/usr/local/bin/mock:$PATH; \
     (/usr/local/bin/install.expect --password "S3cr3tP@ssw0rd" --accept-SAP-developer-license || exit 1; \
       (export LD_LIBRARY_PATH=/sapmnt/NPL/exe/uc/linuxx86_64; \
        python /usr/local/bin/sap_add_trusted_server_cert -v /etc/pki/ca-trust/source/SAP/*.cer); \
      su - npladm -c "stopsap ALL")

# Persist database
# VOLUME [ "/sybase/NPL/sapdata_1" ]

# Here it comes, start your containers without the need to attach/exec and
# start SAP processes manually.
#
# Do not forget to bind mount cgroups:
# -v /sys/fs/cgroup:/sys/fs/cgroup:ro
#
ENTRYPOINT ["/usr/lib/systemd/systemd", "--system"]

# Command sequence to use this Dockerfile

# Before you start, please, configured docker to use devicemapper and set dm.basesize to 60G.
#
# $ docker daemon --storage-opt dm.basesize=60

# To avoid the need to copy the installation files (10s of GBs), mount the directory with
# installation files to /var/tmp/SAPTestDrive.

# Finally, run the build command.
#
# $ docker build \
#    -v $PWD/NW751:/var/tmp/ABAP_Trial \
#    -v $PWD/mock_hostname/ld.so.preload:/etc/ld.so.preload \
#    -v $PWD/mock_hostname/libmockhostname.so:/usr/local/lib64/libmockhostname.so \
#    -t abaptrial:752 .
#
# When built, you can start it this way:
#
# $ docker run -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro --privileged \
#   -p 3200:3200 -p 3300:3300 -p 8000:8000 -p 44300:44300 \
#   --hostname vhcalnplci --name abaptrial abaptrial:752
#
# Tips: you can leave out all the -p arguments and connect to SAP processes
# using the internal IP of the container. Run the following command to get the IP:
#
# $ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' abaptrial
