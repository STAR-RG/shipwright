FROM python:3.6-slim

MAINTAINER Bryce Handerson

COPY . /src

# We should find a way to work around this at some point because it makes
# everything super slow
RUN apt update && apt install -y python3-dev libmagic-dev
RUN pip install /src

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:5000", "pbnh.run:app"]
EXPOSE 5000
