# Example usage:
# docker run --net=host -v /sys:/sys:ro -v /lib/libreadline.so.7.0:/lib/libreadline.so.7.0:ro -v /lib/modules/$(uname -r)/build:/lib/modules/$(uname -r)/build:ro  --privileged --rm -it quay.io/fntlnz/influxdb-ebpf-example:master
FROM golang:1.11

RUN apt-get update -y
RUN apt install apt-transport-https ca-certificates -y
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D4284CDD
RUN echo "deb [trusted=yes] https://repo.iovisor.org/apt/xenial xenial-nightly main" | tee /etc/apt/sources.list.d/iovisor.list
RUN apt-get update -y
RUN cd /tmp && \
  wget -nv -O - https://github.com/fntlnz/kernel-headers/archive/master.tar.gz | tar zx && mv kernel-headers-master/v4.19 /usr/include/linux-headers-4.19 && rm -Rf /tmp/kernel-headers-master
RUN apt-get install bcc-tools libbcc libbcc-examples -y

ADD . /go/src/github.com/fntlnz/influxdb-ebpf-example
WORKDIR /go/src/github.com/fntlnz/influxdb-ebpf-example

RUN make -e OUTPUTFLAGS="-o /influxdb-ebpf-example"

ENTRYPOINT ["/influxdb-ebpf-example"]
