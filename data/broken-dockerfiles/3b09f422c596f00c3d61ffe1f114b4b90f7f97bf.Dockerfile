FROM python:2
ADD . /python-slackbot
WORKDIR /python-slackbot

RUN pip install -r requirements.txt && \
cp example-config/rtmbot.conf .

ENTRYPOINT ["python", "rtmbot.py"]
