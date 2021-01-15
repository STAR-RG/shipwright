FROM python:3.6

ENV env docker

# Django superuser related names
ENV DJANGO_SU_USERNAME root
ENV DJANGO_SU_EMAIL root@root.root
ENV DJANGO_SU_PASS rootroot

RUN mkdir /source
WORKDIR /source

# Copy deps files
ADD Pipfile /source
ADD Pipfile.lock /source

RUN pip install pipenv
RUN pipenv install --system --deploy

ADD . /source/
