FROM ubuntu:trusty

RUN apt-get update && \
    apt-get install -yqq libssl-dev build-essential libffi-dev libxml2-dev \
    libxslt-dev python-dev python-pip git curl wget
    

ADD . /ursula

WORKDIR /ursula

RUN pip install -U pip 

RUN pip install -r requirements.txt

RUN mkdir /root/.ssh

CMD test/setup && test/run deploy
