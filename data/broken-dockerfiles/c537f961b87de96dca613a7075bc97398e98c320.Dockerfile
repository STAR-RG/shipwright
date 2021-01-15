FROM        mlhamel/mlhamel.base

RUN         apt-get update
RUN         apt-get -y upgrade
RUN         apt-get -y install g++ make curl git python-dev
RUN         export LD_LIBRARY_PATH=/usr/local/lib
RUN         cd /home && curl -O https://bootstrap.pypa.io/get-pip.py && python get-pip.py

WORKDIR     /home
RUN         mkdir /home/agendadulibre
COPY        . /home/agendadulibre/
RUN         cd /home/agendadulibre && python setup.py develop

EXPOSE      8000

WORKDIR     /home/agendadulibre
CMD         DJANGO_SETTINGS_MODULE=agenda.settings django-admin.py runserver 0.0.0.0:8000