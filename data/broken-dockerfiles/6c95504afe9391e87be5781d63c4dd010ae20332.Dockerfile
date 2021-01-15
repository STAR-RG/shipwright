FROM ruby:2.7.1
ARG tfver
ARG gover
ENV TERRAFORM_VERSION=$tfver
ENV GOLANG_VERSION=$gover

COPY ["Gemfile", "Rakefile", "/tf-test/"]
COPY build/ /tf-test/build/
RUN apt-get update && gem update --system && apt-get install unzip \
    && curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && curl https://keybase.io/hashicorp/pgp_keys.asc | gpg --import \
    && curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig \
    && gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && shasum -a 256 -c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1 | grep "${TERRAFORM_VERSION}_linux_amd64.zip:\sOK" \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin

RUN apt-get autoremove -y imagemagick

WORKDIR /tf-test/
RUN gem install rake --version =13.0.1 \
    && gem install colorize --version =0.8.1 \
    && gem install rspec --version =3.9.0
WORKDIR /tf-test/module

RUN curl -Os https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz >/dev/null 2>&1 \
    && tar -zxvf go${GOLANG_VERSION}.linux-amd64.tar.gz -C /usr/local/ >/dev/null
ENV PATH /usr/local/go/bin:$PATH
ENV GOPATH $HOME/go
