# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker & https://github/kdelfour/supervisor-docker
# ------------------------------------------------------------------------------
# Pull base image.
FROM ubuntu

# Last base packages update
LABEL BASE_PACKAGES_UPDATE="2015-07-11"
# ------------------------------------------------------------------------------
# Install base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get clean && apt-get update && apt-get install -y build-essential g++ curl libssl-dev apache2-utils git libxml2-dev sshfs make autoconf automake libtool gcc g++ gperf flex bison texinfo gawk ncurses-dev libexpat-dev python sed python-serial srecord bc wget llvm-3.4 libclang1 libclang-dev mc vim screen
RUN apt-get install -y openjdk-7-jre

# ------------------------------------------------------------------------------
# Install Supervisor.
RUN apt-get install -y supervisor
RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

# ------------------------------------------------------------------------------
# Install sshd
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# ------------------------------------------------------------------------------
# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs


# ------------------------------------------------------------------------------
# Versions
ENV VERSION="0.6"
ENV SDK_VERSION "1.2"
ENV SPIFFY_VERSION "1.0.4"


LABEL description="version: ${VERSION}\nsdk: ${SDK_VERSION}\nspiffy: ${SPIFFY_VERSION}"
LABEL release_notes="Update for Sming PR#148"

# ------------------------------------------------------------------------------
# Install yuicompressor
WORKDIR /tmp
RUN wget https://github.com/yui/yuicompressor/releases/download/v2.4.8/yuicompressor-2.4.8.jar
RUN mv /tmp/yuicompressor-2.4.8.jar /usr/local/share/
RUN echo "java -jar /usr/local/share/yuicompressor-2.4.8.jar \"\$@\"" > /usr/local/bin/yuicompressor
RUN chmod 755 /usr/local/bin/yuicompressor


    

# ------------------------------------------------------------------------------
# Install spiffy
WORKDIR /tmp/
RUN wget https://bintray.com/artifact/download/kireevco/generic/spiffy-${SPIFFY_VERSION}-linux-x86_64.tar.gz && tar -zxf spiffy-${SPIFFY_VERSION}-linux-x86_64.tar.gz && mv spiffy /usr/local/bin/ && chmod +rx /usr/local/bin/spiffy


# ------------------------------------------------------------------------------
# Install esp-open-sdk
WORKDIR /tmp/
RUN mkdir -p /opt/esp-open-sdk
RUN wget https://bintray.com/artifact/download/kireevco/generic/esp-open-sdk-${SDK_VERSION}-linux-x86_64.tar.gz && tar -zxf esp-open-sdk-${SDK_VERSION}-linux-x86_64.tar.gz -C /opt/esp-open-sdk
RUN chmod +rx /opt/esp-open-sdk/sdk/tools/gen_appbin.py

# ------------------------------------------------------------------------------
# Install patched esptool
WORKDIR /opt/esp-open-sdk/esptool
RUN mv esptool.py esptool.py_orig
RUN wget https://raw.githubusercontent.com/nodemcu/nodemcu-firmware/master/tools/esptool.py
RUN chmod +rx esptool.py

# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone https://github.com/c9/core.git /opt/cloud9
WORKDIR /opt/cloud9
RUN scripts/install-sdk.sh
RUN npm install

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /opt/cloud9/configs/standalone.js 

# ------------------------------------------------------------------------------
# Add supervisord configs
ADD conf/* /etc/supervisor/conf.d/
# ------------------------------------------------------------------------------
# Create workdir
RUN mkdir -p /root/workspace

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Clone Sming Core
RUN git clone https://github.com/kireevco/Sming.git /opt/sming
RUN ln -s /opt/sming /root/sming-examples


# ------------------------------------------------------------------------------
# Enviromnent settings
ENV ESP_HOME="/opt/esp-open-sdk"
ENV SMING_HOME="/opt/sming/Sming"
ENV CXX="/opt/esp-open-sdk/xtensa-lx106-elf/bin/xtensa-lx106-elf-g++"
ENV CC="/opt/esp-open-sdk/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc"
ENV PATH="/opt/esp-open-sdk/xtensa-lx106-elf/bin:${PATH}"
ENV CPATH="\
${ESP_HOME}/sdk/include:\
${SMING_HOME}:\
${SMING_HOME}/include:\
${SMING_HOME}/SmingCore:\
${SMING_HOME}/system/include:\
${SMING_HOME}/Libraries:\
${SMING_HOME}/Services:\
${SMING_HOME}/Wiring:\
/opt/sming:\
./include\
"

ENV LIBRARY_PATH="\
${SMING_HOME}/compiler/lib:\
"

ENV COM_SPEED_ESPTOOL=230400

RUN env > /etc/environment

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 22
EXPOSE 80
EXPOSE 10000


# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
