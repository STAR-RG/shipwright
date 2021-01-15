FROM python:3-slim
LABEL "MAINTAINER"="Otomato Software Ltd. <contact@otomato.link>"
ADD . /birdwatch/
WORKDIR /birdwatch
RUN pip3 install -r requirements.txt

ENTRYPOINT  ["python", "-u", "controller.py"]
