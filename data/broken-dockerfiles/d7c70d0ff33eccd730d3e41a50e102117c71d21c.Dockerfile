from ubuntu
MAINTAINER Charlie Lewis <charlie.lewis42@gmail.com>

ENV REFRESHED_AT 2013-11-17
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y git
RUN apt-get install -y python-setuptools
RUN apt-get install -y redis-server
RUN easy_install pip
ADD . /wharf
RUN pip install -r /wharf/requirements.txt
ADD patch/auth.py /usr/local/lib/python2.7/dist-packages/docker/auth/auth.py
ADD patch/client.py /usr/local/lib/python2.7/dist-packages/docker/client.py

EXPOSE 5000

WORKDIR /wharf
CMD ["python", "runserver.py"]
