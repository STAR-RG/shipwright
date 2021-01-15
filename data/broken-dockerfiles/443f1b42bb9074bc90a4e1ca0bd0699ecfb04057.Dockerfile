FROM debian:stable
MAINTAINER Cole Gleason <cagleas2@illinois.edu>
RUN apt-get update && apt-get -y install build-essential \
    nginx \
    supervisor \
    sqlite3 \
    imagemagick \
    python \
    python-dev \
    python-setuptools \
    uwsgi \
    libmysqlclient-dev \
    libldap2-dev \
    libsasl2-dev \
    python-pip \
    ssh

RUN pip install uwsgi
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default

ADD docker /liquid
ADD liquid /liquid/app

WORKDIR /liquid
RUN find . -name "*.pyc" -delete

RUN mv wsgi.py app/wsgi.py
RUN mv local_settings.py app/local_settings.py
RUN pip install -r app/requirements.txt

RUN python app/manage.py syncdb --noinput
RUN python app/manage.py migrate

# setup all the configfiles
RUN ln -s /liquid/nginx-liquid.conf /etc/nginx/sites-enabled/
RUN ln -s /liquid/supervisor.conf /etc/supervisor/conf.d/

ENV LIQUID_SMTP_HOST engr-acm-web-02.acm.illinois.edu

EXPOSE 80
CMD ["/liquid/run.sh"]
