FROM ubuntu:13.10
MAINTAINER Jann Kleen "jann@resmio.com"
VOLUME ["/var/pootledb"]
RUN apt-get -qq update
RUN apt-get install -y python-dev python-setuptools git build-essential libxml2-dev libxslt-dev libxml2 libxslt1.1 zlib1g-dev
RUN easy_install pip
RUN pip install virtualenv
RUN virtualenv /var/www/pootle/env
RUN /var/www/pootle/env/bin/pip install Pootle==2.5.1.1
RUN /var/www/pootle/env/bin/pip install django-tastypie==0.12.1
RUN mkdir -p /var/local/pootledb
RUN /var/www/pootle/env/bin/pootle init
RUN sed -i "s/\('NAME' *: *\).*/\1'\/var\/local\/pootledb\/pootle.db',/" ~/.pootle/pootle.conf
RUN /var/www/pootle/env/bin/pootle setup
RUN /var/www/pootle/env/bin/pootle collectstatic --noinput
RUN /var/www/pootle/env/bin/pootle assets build
RUN grep -q '^POOTLE_ENABLE_API' ~/.pootle/pootle.conf && sed -i "s/\(POOTLE_ENABLE_API *= *\).*/\1True/" ~/.pootle/pootle.conf || echo "\nPOOTLE_ENABLE_API = True\n" >> ~/.pootle/pootle.conf
RUN grep -q '^ALLOWED_HOSTS' ~/.pootle/pootle.conf && sed -i "s/\(ALLOWED_HOSTS *= *\).*/\1\[\"\*\", \]/" ~/.pootle/pootle.conf || echo "\nALLOWED_HOSTS = [\"*\", ]\n" >> ~/.pootle/pootle.conf
ADD run.sh /usr/local/bin/run
EXPOSE 8000
CMD /bin/bash /usr/local/bin/run

