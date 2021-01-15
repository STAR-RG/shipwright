FROM python:3.6-alpine

RUN mkdir -p /var/sqlite3/

WORKDIR /usr/src/app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .
