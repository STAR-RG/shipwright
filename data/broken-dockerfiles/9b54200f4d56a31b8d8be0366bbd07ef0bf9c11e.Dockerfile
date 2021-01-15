FROM debian

MAINTAINER Romain Commandé, commande.romain@gmail.com

RUN apt-get update && apt-get upgrade -y && apt-get install -y build-essential python3-dev libzmq3-dev libxml2-dev libxslt1-dev python3-pip libffi-dev libssl-dev && apt-get clean && apt-get autoclean && apt-get autoremove
RUN apt-get install -y python3-pip
RUN pip3 install -U pip
RUN pip3 install virtualenv
RUN virtualenv -p python3 /srv/papaye-venv
RUN /srv/papaye-venv/bin/pip install -U pip gunicorn wheel pyopenssl
RUN mkdir /srv/papaye
RUN mkdir /srv/papaye/packages
RUN mkdir /srv/papaye/cache
RUN /srv/papaye-venv/bin/pip install wheel pyopenssl persistent
COPY . /srv/papaye
WORKDIR /srv/papaye/
RUN /srv/papaye-venv/bin/pip install -r /srv/papaye/requirements/requirements.txt
RUN /srv/papaye-venv/bin/pip install -e .
CMD /srv/papaye-venv/bin/papaye_init --user admin --password admin /srv/papaye/docker.ini && /srv/papaye-venv/bin/papaye_evolve /srv/papaye/docker.ini && /srv/papaye-venv/bin/gunicorn --paster /srv/papaye/docker.ini
