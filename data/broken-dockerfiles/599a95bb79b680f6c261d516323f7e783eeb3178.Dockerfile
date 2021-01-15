# Dev environment
#
# Makes a virtualenv at /venv which might need updating but should
# have a good base of dependencies.
#
# e.g.
#
# docker run --rm -t -i -v $PWD:$PWD jbothma/municipal-data:docker-dev-env bin/bash
# root@079d0a9aae0d:/# cd /home/jdb/proj/code4sa/municipal_finance/django-app/
# root@079d0a9aae0d:/home/jdb/proj/code4sa/municipal_finance/django-app# source /venv/bin/activate
# root@079d0a9aae0d:/home/jdb/proj/code4sa/municipal_finance/django-app# export DATABASE_URL=postgres://municipal_finance@172.17.0.1/municipal_finance
# root@079d0a9aae0d:/home/jdb/proj/code4sa/municipal_finance/django-app# python manage.py runserver 0.0.0.0:8000



FROM python:3.6-alpine

ENV PYTHONUNBUFFERED 1

RUN apk update \
  # psycopg2 dependencies
  && apk add --virtual build-deps gcc python3-dev musl-dev \
  && apk add postgresql-dev \
  # Pillow dependencies
  && apk add jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev \
  # CFFI dependencies
  && apk add libffi-dev py-cffi \
  # Translations dependencies
  && apk add gettext \
  # https://docs.djangoproject.com/en/dev/ref/django-admin/#dbshell
  && apk add postgresql-client

ADD requirements.txt /requirements.txt

RUN pip install -r /requirements.txt

CMD ["/bin/bash"]
