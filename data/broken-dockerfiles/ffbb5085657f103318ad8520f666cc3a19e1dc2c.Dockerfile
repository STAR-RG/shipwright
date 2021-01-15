# Docker image for Tweet-Toot project.
FROM python:3.7-alpine
LABEL Author="ayush@ayushsharma.in"

COPY . /tweet-toot

WORKDIR /tweet-toot

RUN pip3 install -r requirements.txt

CMD ["python3", "run.py"]