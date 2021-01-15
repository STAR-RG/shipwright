FROM python:3 AS poetry
ENV PATH="/root/.poetry/bin:${PATH}"
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python


FROM poetry AS base
RUN mkdir /app
WORKDIR /app
COPY pyproject.* .
RUN poetry install -n --extras=docker
COPY . /app


FROM base AS Test
RUN poetry run pytest -m "not docker"
