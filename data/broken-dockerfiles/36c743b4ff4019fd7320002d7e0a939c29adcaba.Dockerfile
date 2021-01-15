FROM alpine:latest
MAINTAINER Alberto Lamela <alberto.lamela@capgemini.com>

ENV DCOS_CONFIG=/dcos-cli/.dcos/dcos.toml
ENV DCOS_CLI_VERSION=0.3.0

RUN apk --update add \
		bash \
		curl \
		python \
		py-pip

RUN pip install virtualenv==14.0.6

RUN mkdir /dcos-cli
RUN mkdir /dcos-cli/.dcos
COPY config.sh /dcos-cli/config.sh
COPY setup.sh /dcos-cli/setup.sh
COPY dcos-cli.sh /usr/local/bin/dcos-cli.sh

RUN /bin/bash /dcos-cli/config.sh
RUN /bin/bash /dcos-cli/setup.sh

ENTRYPOINT ["/usr/local/bin/dcos-cli.sh"]

