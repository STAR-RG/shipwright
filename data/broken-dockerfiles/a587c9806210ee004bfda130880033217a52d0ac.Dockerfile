FROM perl:5.20
MAINTAINER Sven Dowideit <SvenDowideit@home.org.au>

RUN cpanm Module::Build::Tiny
RUN cpanm Moo
#', '1.002000';
RUN cpanm JSON
RUN cpanm JSON::XS
RUN cpanm LWP::UserAgent
RUN cpanm LWP::Protocol::http::SocketUnixAlt
RUN cpanm URI
RUN cpanm AnyEvent
RUN cpanm AnyEvent::HTTP
RUN cpanm IO::String

COPY . /docker-perl
WORKDIR /docker-perl

RUN cpanm --installdeps .
RUN perl Build.PL
RUN ./Build build

# This is a terrible cheat.
ENV DOCKER_HOST http://10.10.10.4:2375

RUN ./Build test
RUN ./Build install

CMD ["docker.pl", "ps"]

