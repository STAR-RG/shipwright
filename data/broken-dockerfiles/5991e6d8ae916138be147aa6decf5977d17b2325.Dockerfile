# Pull base image
FROM resin/rpi-raspbian:jessie
MAINTAINER Talmai Oliveira <to@talm.ai>
LABEL "ai.talm.rpi-watchtower"="true"

COPY rpi-watchtower_ARM5 /
COPY rpi-watchtower_ARM6 /
COPY rpi-watchtower_ARM7 /
COPY run_watchtower.sh /

ENTRYPOINT ["/run_watchtower.sh"]
CMD ["5"] #defaults to ARM5 binary