FROM python:2
USER root
ENV LOGNAME buster

RUN pip install git+https://github.com/raccoonyy/buster.git#egg=buster
RUN mkdir /deploy

WORKDIR /deploy
COPY scripts/      /deploy/
RUN  chmod a+x     /deploy/*.sh

CMD ["./run.sh"]