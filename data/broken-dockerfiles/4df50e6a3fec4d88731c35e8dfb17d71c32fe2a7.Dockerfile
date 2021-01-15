FROM ruby:2.4.1

ENV GEM_NAME ops_manager_cli
ENV GEM_VERSION 0.7.14
ENV SPRUCE_VERSION 1.19.1
ENV JQ_VERSION 1.5
ENV OM_VERSION 0.42.0
ENV OVFTOOL_VERSION 4.3.0-7948156
ENV OVFTOOL_INSTALLER VMware-ovftool-${OVFTOOL_VERSION}-lin.x86_64.bundle
ARG DOWNLOAD_URL

# ================== Installs sshpass ===============
#RUN echo "deb http://httpredir.debian.org/debian jessie utils" >> sources.list
RUN apt-get update \
 && apt-get install -y sshpass unzip \
 && rm -rf /var/lib/apt/lists/*

# ================== Installs OVF tools ==============
RUN wget -q --no-check-certificate ${DOWNLOAD_URL} \
 && sh ${OVFTOOL_INSTALLER} -p /usr/local --eulas-agreed --required \
 && rm -f ${OVFTOOL_INSTALLER}*

# ================== Installs Spruce ==============
RUN wget -v -O /usr/local/bin/spruce --no-check-certificate https://github.com/geofffranks/spruce/releases/download/v${SPRUCE_VERSION}/spruce-linux-amd64 \
 && chmod +x /usr/local/bin/spruce

# ================== Installs JQ ==============
RUN wget -q -O /usr/local/bin/jq --no-check-certificate https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 \
 && chmod +x /usr/local/bin/jq

#============ Installs Om ============
RUN wget -q -O /usr/local/bin/om --no-check-certificate https://github.com/pivotal-cf/om/releases/download/${OM_VERSION}/om-linux \
  && chmod +x /usr/local/bin/om

# ================== Installs ops_manager_cli gem ==============
COPY pkg/${GEM_NAME}-${GEM_VERSION}.gem /tmp/
RUN echo ':ssl_verify_mode: 0' > ~/.gemrc \
 && gem install /tmp/${GEM_NAME}-${GEM_VERSION}.gem
