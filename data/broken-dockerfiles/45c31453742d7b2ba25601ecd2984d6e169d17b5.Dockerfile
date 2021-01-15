FROM fedora:24
EXPOSE 5000
WORKDIR /spacewiki/app/
VOLUME /data

RUN dnf -y update && \
    dnf install -y ruby rubygems && \
    gem install pups

ADD docker/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["runserver", "-s"]

ADD . /spacewiki/git/
RUN pups /spacewiki/git/docker/build.yaml
