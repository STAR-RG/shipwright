FROM ubuntu:wily
MAINTAINER Gastón Avila "avila.gas@gmail.com"

RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential libpq-dev
RUN pip install pip --upgrade

RUN mkdir /srv/app
WORKDIR /srv/app
ADD ./requirements.txt /srv/app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# ADD . /srv/app

ENV PYTHONUNBUFFERED=1
EXPOSE 5000

CMD honcho start web
