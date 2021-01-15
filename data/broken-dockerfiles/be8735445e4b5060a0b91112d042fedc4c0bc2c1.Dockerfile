FROM python:3.7-alpine

COPY . /app
WORKDIR /app

RUN pip install pipenv && pipenv install --dev

CMD ["pipenv", "run", "pytest"]
