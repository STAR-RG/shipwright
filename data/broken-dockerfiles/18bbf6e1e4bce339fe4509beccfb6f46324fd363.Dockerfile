FROM ubuntu:14.04

RUN apt-get update

RUN apt-get -yq install git python-setuptools python-dev libc6-dev build-essential

RUN easy_install pip

RUN pip install --no-deps easy_thumbnails

RUN pip install virtualenv

RUN pip install virtualenvwrapper

RUN apt-get -yq install libjpeg-dev zlib1g-dev

RUN pip install Pillow

RUN pip install Django==1.4.20

RUN pip install South

RUN pip install django_debug_toolbar==1.3.2

RUN pip install django-extensions

RUN pip install django-user-accounts==1.0b3

RUN pip install django-forms-bootstrap==2.0.3.post1

RUN pip install metron==1.0

RUN pip install webtest

RUN pip install django-webtest

RUN pip install django-notification

COPY . /var/www/valuenetwork

WORKDIR /var/www/valuenetwork

RUN pip install -r requirements.txt --trusted-host dist.pinaxproject.com

RUN ./manage.py syncdb --noinput

RUN ./manage.py migrate

RUN ./manage.py loaddata ./fixtures/starters.json

RUN ./manage.py loaddata ./fixtures/help.json

RUN /bin/bash -c 'cp valuenetwork/local_settings{_development,}.py'

COPY ./cmd/create-user.sh /usr/local/bin/create-user.sh

RUN chmod +x /usr/local/bin/create-user.sh

RUN /usr/local/bin/create-user.sh

EXPOSE 8000

COPY ./cmd/run-server.sh /usr/local/bin/run-server.sh

RUN chmod +x /usr/local/bin/run-server.sh

VOLUME /var/www/valuenetwork

CMD ["/usr/local/bin/run-server.sh"]
