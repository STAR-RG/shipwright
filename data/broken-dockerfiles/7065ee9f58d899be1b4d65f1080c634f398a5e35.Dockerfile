FROM ubuntu:trusty

MAINTAINER Joshua Peper <joshua@peperzaken.nl>

RUN apt-get update
RUN apt-get install -y build-essential python python-dev python-pip

RUN easy_install pip

VOLUME ["/data"]

ADD . /app/

WORKDIR /app

RUN chmod +x deploy/run.sh

RUN pip install -r requirements.txt

RUN chmod +x /app/deploy/bootstrap.sh

RUN	/app/deploy/bootstrap.sh && \
	python manage.py collectstatic --noinput --ignore /data/

EXPOSE 80
CMD ["/app/deploy/run.sh"]
