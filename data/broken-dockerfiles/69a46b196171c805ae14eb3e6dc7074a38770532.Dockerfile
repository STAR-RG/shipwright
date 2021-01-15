FROM debian:wheezy

MAINTAINER vhb <vctrhb@gmail.com>

#ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update --quiet \
        && apt-get install \
            --yes \
            --no-install-recommends \
            --no-install-suggests \
            boinc-client python \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
ADD run.py /bin/

CMD []

ENTRYPOINT ["/bin/run.py"]
