FROM gliderlabs/alpine

ENV FACTER_VERSION 2.4.6

# Install any dependencies needed
RUN apk update && \
    apk add bash sed dmidecode ruby ruby-irb open-lldp util-linux open-vm-tools sudo && \
    apk add lshw ipmitool --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && \
    echo "install: --no-rdoc --no-ri" > /etc/gemrc && \
    gem install json_pure daemons && \
    gem install facter -v ${FACTER_VERSION} && \
    find /usr/lib/ruby/gems/2.2.0/gems/facter-${FACTER_VERSION} -type f -exec sed -i 's:/proc/:/host-proc/:g' {} + && \
    find /usr/lib/ruby/gems/2.2.0/gems/facter-${FACTER_VERSION} -type f -exec sed -i 's:/dev/:/host-dev/:g' {} + && \
    find /usr/lib/ruby/gems/2.2.0/gems/facter-${FACTER_VERSION} -type f -exec sed -i 's:/host-dev/null:/dev/null:g' {} + && \
    find /usr/lib/ruby/gems/2.2.0/gems/facter-${FACTER_VERSION} -type f -exec sed -i 's:/sys/:/host-sys/:g' {} +
ADD hnl_mk*.rb /usr/local/bin/
ADD hanlon_microkernel/*.rb /usr/local/lib/ruby/hanlon_microkernel/
