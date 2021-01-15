FROM python:3.7-alpine
RUN apk update
RUN apk add py3-mysqlclient git
RUN pip3 install --upgrade pip
ADD requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt
RUN apk del git
RUN addgroup -S freezing && adduser -S -G freezing freezing
ADD . /app
RUN mkdir -p /data
COPY leaderboards /data/leaderboards
WORKDIR /app
ENV LEADERBOARDS_DIR=/data/leaderboards
USER freezing
EXPOSE 8000
ENTRYPOINT gunicorn --bind 0.0.0.0:8000 'freezing.web:app'
