# * Dockerfile for glima
#   https://github.com/yoshinari-nomura/glima
#
# * How to buld
# ** from command line
#    bundle exec rake build
#    docker build --build-arg GLIMA_VERSION=$(bundle exec glima version) -t nom4476/glima .
#
# ** from Rakefile
#    bundle exec rake docker:build
#
# * How to run
#   mkdir -p ~/.config/glima ~/.cache/glima
#
#   docker run -it --rm \
#     -v $HOME/.config/glima:/root/.config/glima \
#     -v $HOME/.cache/glima:/root/.cache/glima   \
#     nom4476/glima init
#
#   docker run -it --rm \
#     -v $HOME/.config/glima:/root/.config/glima \
#     -v $HOME/.cache/glima:/root/.cache/glima   \
#     nom4476/glima init
#
# * For debug
#   docker run -it --rm -v $HOME/.config/glima:/root/.config/glima --entrypoint "sh" nom4476/glima
#
#
FROM alpine:3.6

MAINTAINER nom@quickhack.net

RUN mkdir -p $HOME/.config/glima
RUN mkdir -p $HOME/.cache/glima

RUN echo 'gem: --no-ri --no-rdoc' > $HOME/.gemrc

RUN apk --update add ruby ruby-json && rm -rf /var/cache/apk/*

ARG GLIMA_VERSION
ENV GLIMA_VERSION $GLIMA_VERSION
ENV RUBYOPT "-W0"
RUN test -n "$GLIMA_VERSION"

COPY pkg/glima-${GLIMA_VERSION}.gem /tmp
RUN  gem install /tmp/glima-$GLIMA_VERSION.gem

ENTRYPOINT [ "glima" ]
CMD [ "help" ]
