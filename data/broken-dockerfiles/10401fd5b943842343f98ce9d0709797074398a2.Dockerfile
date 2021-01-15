FROM python:3.4
ENV PYTHONUNBUFFERED 1
ENV WITH_DOCKER True
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt
ADD . /code/
