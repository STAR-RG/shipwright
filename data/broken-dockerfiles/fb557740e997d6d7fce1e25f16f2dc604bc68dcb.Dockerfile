FROM python:2.7

MAINTAINER Antonio Mika <me@antoniomika.me>

ADD . /MHacks-Website
WORKDIR /MHacks-Website

RUN pip install pillow
RUN pip install -r requirements.txt

RUN useradd -ms /bin/bash mhacks
USER mhacks

ENTRYPOINT ["python", "manage.py"]

EXPOSE 8000