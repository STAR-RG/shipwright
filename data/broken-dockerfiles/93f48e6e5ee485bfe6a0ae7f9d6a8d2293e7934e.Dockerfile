FROM resin/rpi-raspbian

# Install all required packages
RUN apt-get update
# gettext is required for envsubst (used in cmd.sh)
RUN apt-get install -y build-essential \
                       gettext \
                       git \
                       iproute2 \
                       iputils-ping \
                       libftdi-dev \
                       python-dev \
                       swig \
                       WiringPi

# Get the code for the ic880a-gateway
RUN git clone -b spi https://github.com/ttn-zh/ic880a-gateway.git ~/ic880a-gateway

ENV INSTALL_DIR /opt/ttn-gateway
RUN git clone https://github.com/devttys0/libmpsse.git $INSTALL_DIR/libmpsse
WORKDIR $INSTALL_DIR/libmpsse/src
RUN ./configure --disable-python
RUN make
RUN make install
RUN ldconfig

RUN git clone -b legacy https://github.com/TheThingsNetwork/lora_gateway.git $INSTALL_DIR/lora_gateway

RUN cp $INSTALL_DIR/lora_gateway/libloragw/99-libftdi.rules /etc/udev/rules.d/99-libftdi.rules
RUN sed -i -e 's/PLATFORM= kerlink/PLATFORM= imst_rpi/g' $INSTALL_DIR/lora_gateway/libloragw/library.cfg

WORKDIR $INSTALL_DIR/lora_gateway
RUN make

RUN git clone -b legacy https://github.com/TheThingsNetwork/packet_forwarder.git $INSTALL_DIR/packet_forwarder
WORKDIR $INSTALL_DIR/packet_forwarder
RUN make
RUN mkdir $INSTALL_DIR/bin
RUN ln -s $INSTALL_DIR/packet_forwarder/poly_pkt_fwd/poly_pkt_fwd $INSTALL_DIR/bin/poly_pkt_fwd
RUN cp -f $INSTALL_DIR/packet_forwarder/poly_pkt_fwd/global_conf.json $INSTALL_DIR/bin/global_conf.json

RUN cp ~/ic880a-gateway/start.sh $INSTALL_DIR/bin/

COPY local_conf_template.json $INSTALL_DIR/bin/
COPY cmd.sh $INSTALL_DIR/bin/

WORKDIR $INSTALL_DIR/bin
CMD ./cmd.sh

