FROM jimmycuadra/rust:1.1.0
MAINTAINER Mesosphere <support@mesosphere.io>

ADD . /star
WORKDIR /star
RUN cargo build
ENTRYPOINT ["target/debug/star-probe"]
