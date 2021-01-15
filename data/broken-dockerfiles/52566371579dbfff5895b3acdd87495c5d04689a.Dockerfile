FROM ubuntu

MAINTAINER Virginie Van den Schrieck, virginie.vandenschrieck@pythia-project.org

# Build utilities
RUN cat /etc/resolv.conf
RUN apt-get update  \
		&& apt-get install -y gcc libc6-dev make curl wget xz-utils\
               ca-certificates bzip2 --no-install-recommends \
		&& rm -rf /var/lib/apt/lists/*


#Install Go
ENV GOLANG_GOOS linux
ENV GOLANG_GOARCH amd64
ENV GOLANG_VERSION 1.5

RUN curl -k -sSL https://golang.org/dl/go$GOLANG_VERSION.$GOLANG_GOOS-$GOLANG_GOARCH.tar.gz \
		| tar -v -C /usr/local -xz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" \
		&& chmod -R 777 "$GOPATH"

WORKDIR $GOPATH

#COPY go-wrapper /usr/local/bin/

#Install Git

RUN apt-get update \ 
	&&apt-get install -y git
	
#Install other utilities

RUN apt-get update \
	&& apt-get install -y fakeroot squashfs-tools libc6-dev-i386 bc

#Install Pythia

WORKDIR /home
RUN git clone https://github.com/pythia-project/pythia-core.git pythia
RUN ls && pwd
WORKDIR /home/pythia/
RUN git submodule update --init --recursive && make


#Change fstab to have shm in no-exec mode for UML
RUN echo "tmpfs /dev/shm tmpfs defaults,nosuid,nodev 0 0" >> /etc/fstab && echo "">>/etc/fstab

#TODO manually when running in privileged mode : mount /dev/shm

