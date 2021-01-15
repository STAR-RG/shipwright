FROM ubuntu:15.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q git autoconf build-essential sudo gperf bison flex texinfo libtool libtool-bin libncurses5-dev wget gawk libc6 python-serial libexpat-dev
RUN useradd -d /opt/Espressif -m -s /bin/bash esp32
RUN usermod -aG sudo esp32
USER root
ADD /sudoers.txt /etc/sudoers
RUN chmod 440 /etc/sudoers
USER esp32
RUN cd /opt/Espressif/ && git clone -b esp108-1.21.0 git://github.com/jcmvbkbc/crosstool-NG.git
RUN cd /opt/Espressif/crosstool-NG && ./bootstrap && ./configure --prefix=`pwd` && make
run cd /opt/Espressif/crosstool-NG && sudo make install
RUN cd /opt/Espressif/crosstool-NG && ./ct-ng xtensa-esp108-elf
RUN cd /opt/Espressif/crosstool-NG && ./ct-ng build
ENV PATH /opt/Espressif/crosstool-NG/builds/xtensa-esp108-elf/bin:$PATH
RUN chmod a+rw /opt/Espressif/
RUN mkdir /opt/Espressif/esptool32
ADD /esptool32.py /opt/Espressif/esptool32
ENV PATH /opt/Espressif/esptool32:$PATH
RUN mkdir /opt/Espressif/Workspace
RUN chmod a+rw /opt/Espressif/Workspace
RUN cd /opt/Espressif/Workspace && git clone https://github.com/espressif/ESP32_RTOS_SDK.git
RUN mkdir /opt/Espressif/Workspace/ESP32_BIN
ENV SDK_PATH /opt/Espressif/Workspace/ESP32_RTOS_SDK
ENV BIN_PATH /opt/Espressif/Workspace/ESP32_BIN
RUN cp -R /opt/Espressif/Workspace/ESP32_RTOS_SDK/examples/project_template/ /opt/Espressif/Workspace/
RUN chmod u+x /opt/Espressif/Workspace/project_template/gen_misc.sh
RUN cd /opt/Espressif/Workspace/project_template && ./gen_misc.sh
#RUN python /opt/Espressif/esptool32/esptool32.py
