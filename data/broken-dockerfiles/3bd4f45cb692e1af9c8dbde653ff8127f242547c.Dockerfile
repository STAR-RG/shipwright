FROM python:3.6

# get Poetry
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python

# opencv and dlib require some system deps
RUN apt-get -qq update
RUN apt-get -qq install cmake libboost-python-dev

RUN mkdir /app
WORKDIR /app
COPY ./src /src
WORKDIR /src
COPY ./pyproject.toml .
COPY ./poetry.lock .

RUN . $HOME/.poetry/env && poetry config settings.virtualenvs.create false
RUN . $HOME/.poetry/env && poetry install --no-interaction --no-dev

# gunicorn is used as a wsgi server
RUN pip install gunicorn